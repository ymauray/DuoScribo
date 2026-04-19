import SwiftUI
import SwiftData

struct StreakFlameView: View {
    let streak: Int
    let isActive: Bool
    
    @State private var pulseScale = 1.0
    @State private var burstScale = 1.0
    
    var body: some View {
        VStack(spacing: -10) {
            ZStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 120))
                    .foregroundColor(isActive ? .orange.opacity(0.2) : .clear)
                    .offset(y: 5)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 120))
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(
                        isActive ? 
                        AnyShapeStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)) : 
                        AnyShapeStyle(Color.gray.opacity(0.3))
                    )
                    .scaleEffect(isActive ? pulseScale : 1.0)
                    .scaleEffect(burstScale)
                
                Text("\(streak)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(isActive ? (Color(uiColor: .label)) : .gray)
                    .offset(y: 25)
            }
            
            Text(isActive ? "SÉRIE ACTIVE !" : "À COMPLÉTER")
                .font(.system(.caption, design: .rounded).bold())
                .foregroundColor(isActive ? .orange : .gray)
                .padding(.top, 20)
        }
        .contentShape(Rectangle())
        .onAppear {
            updateAnimation()
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                triggerBurst()
            }
            updateAnimation()
        }
    }
    
    private func updateAnimation() {
        if isActive {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        } else {
            withAnimation(.default) {
                pulseScale = 1.0
            }
        }
    }
    
    private func triggerBurst() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)) {
            burstScale = 1.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) {
                burstScale = 1.0
            }
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [.orange, .yellow, .red]
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { i in
                Circle()
                    .fill(colors.randomElement()!)
                    .frame(width: CGFloat.random(in: 5...12))
                    .offset(x: animate ? CGFloat.random(in: -150...150) : 0,
                            y: animate ? CGFloat.random(in: -200...200) : 0)
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.5 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserStats.totalPoints, order: .reverse) private var stats: [UserStats]
    @Query(sort: \WritingEntry.date, order: .reverse) private var entries: [WritingEntry]
    
    @State private var showingEditor = false
    @State private var showingInfo = false
    @State private var editingEntry: WritingEntry? = nil
    @State private var resetTapCount = 0
    @State private var showingResetAlert = false
    @State private var showConfetti = false
    
    private var userStats: UserStats {
        if let existing = stats.first {
            return existing
        } else {
            let newStats = UserStats()
            modelContext.insert(newStats)
            return newStats
        }
    }
    
    private var hasWrittenToday: Bool {
        guard let lastDate = userStats.lastWritingDate else { return false }
        return Calendar.current.isDate(lastDate, inSameDayAs: Date())
    }
    
    private var groupedEntries: [(Date, [WritingEntry])] {
        let groups = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.date ?? Date())
        }
        return groups.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    // Section unique pour le Tableau de Bord (Flamme + Stats + Bouton)
                    Section {
                        VStack(spacing: 35) {
                            StreakFlameView(streak: userStats.currentStreak ?? 0, isActive: hasWrittenToday)
                                .padding(.top, 20)
                                .onTapGesture { handleFlameTap() }
                            
                            HStack(spacing: 15) {
                                statCard(title: "POINTS", value: "\(userStats.totalPoints ?? 0)", color: .yellow, icon: "star.fill")
                                statCard(title: "RECORD", value: "\(userStats.longestStreak ?? 0)j", color: .blue, icon: "trophy.fill")
                            }
                            
                            Button(action: { showingEditor = true }) {
                                HStack {
                                    Image(systemName: hasWrittenToday ? "pencil.and.outline" : "bolt.fill")
                                    Text(hasWrittenToday ? "Continuer à écrire" : "Prolonger ma série")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(hasWrittenToday ? Color.gray : Color.orange)
                                .cornerRadius(16)
                                .shadow(color: (hasWrittenToday ? Color.primary : Color.orange).opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)

                            Text("Glisser un texte à droite pour le copier, à gauche pour le supprimer")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.top, -10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                    
                    if entries.isEmpty {
                        Section(header: Text("VOS RÉCITS").font(.caption.bold())) {
                            Text("Prêt à écrire ? Vos textes apparaîtront ici.")
                                .foregroundColor(.gray)
                                .italic()
                        }
                    } else {
                        ForEach(groupedEntries, id: \.0) { date, dayEntries in
                            Section(header: dailyHeader(date: date, entries: dayEntries)) {
                                ForEach(dayEntries) { entry in
                                    entryRow(for: entry)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            editingEntry = entry
                                        }
                                        .swipeActions(edge: .trailing) {
                                            if Calendar.current.isDate(entry.date ?? Date(), inSameDayAs: Date()) {
                                                Button(role: .destructive) {
                                                    deleteEntry(entry)
                                                } label: {
                                                    Label("Supprimer", systemImage: "trash")
                                                }
                                            }
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                UIPasteboard.general.string = entry.content ?? ""
                                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                            } label: {
                                                Label("Copier", systemImage: "doc.on.doc")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            }
                        }
                    }
                }
                
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("DuoScribo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .sheet(isPresented: $showingInfo) {
                PointsInfoView()
            }
            .sheet(isPresented: $showingEditor) {
                EditorView(stats: userStats)
            }
            .sheet(item: $editingEntry) { entry in
                EditorView(stats: userStats, entryToEdit: entry)
            }
            .onChange(of: hasWrittenToday) { oldValue, newValue in
                if newValue && !oldValue {
                    withAnimation { showConfetti = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showConfetti = false
                    }
                }
            }
            .alert("Réinitialisation complète ?", isPresented: $showingResetAlert) {
                Button("Annuler", role: .cancel) { resetTapCount = 0 }
                Button("Tout effacer", role: .destructive) { performFullReset() }
            } message: {
                Text("Cela va supprimer tous vos textes, vos points et votre série. Cette action est irréversible.")
            }
        }
        .tint(.orange)
    }
    
    private func dailyHeader(date: Date, entries: [WritingEntry]) -> some View {
        let totalWords = entries.reduce(0) { $0 + ($1.wordCount ?? 0) }
        return HStack {
            Text(date, style: .date)
                .font(.caption.bold())
            Spacer()
            Text("\(totalWords) mots au total")
                .font(.caption)
                .foregroundColor(.orange)
        }
    }
    
    private func handleFlameTap() {
        resetTapCount += 1
        if resetTapCount >= 7 {
            showingResetAlert = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !showingResetAlert { resetTapCount = 0 }
        }
    }
    
    @MainActor
    private func performFullReset() {
        for entry in entries {
            modelContext.delete(entry)
        }
        userStats.totalPoints = 0
        userStats.currentStreak = 0
        userStats.longestStreak = 0
        userStats.lastWritingDate = nil
        try? modelContext.save()
        resetTapCount = 0
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    private func statCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.caption.bold()).foregroundColor(.gray)
            }
            Text(value).font(.system(.title2, design: .rounded).bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func entryRow(for entry: WritingEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date ?? Date(), style: .time)
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                HStack(spacing: 4) {
                    if (entry.wordCount ?? 0) >= 250 {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                    Text("\(entry.wordCount ?? 0) mots")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Text(entry.content ?? "")
                .lineLimit(3)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
    
    @MainActor
    private func deleteEntry(_ entry: WritingEntry) {
        withAnimation {
            modelContext.delete(entry)
            StreakManager.shared.updateStats(in: userStats, allEntries: entries.filter { $0.id != entry.id })
            if !hasWrittenToday {
                NotificationManager.shared.scheduleDailyReminder()
            }
        }
    }
}

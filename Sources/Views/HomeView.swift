import SwiftUI
import SwiftData

struct StreakFlameView: View {
    let streak: Int
    let isActive: Bool
    
    @State private var scale = 1.0
    
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
                    .scaleEffect(scale)
                
                Text("\(streak)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(isActive ? Color(red: 0.05, green: 0.1, blue: 0.3) : .gray)
                    .offset(y: 25)
            }
            
            Text(isActive ? "SÉRIE ACTIVE !" : "À COMPLÉTER")
                .font(.system(.caption, design: .rounded).bold())
                .foregroundColor(isActive ? .orange : .gray)
                .padding(.top, 20)
        }
        .contentShape(Rectangle()) // Rend toute la zone cliquable
        .onAppear {
            if isActive {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
        }
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stats: [UserStats]
    @Query(sort: \WritingEntry.date, order: .reverse) private var entries: [WritingEntry]
    
    @State private var showingEditor = false
    @State private var resetTapCount = 0
    @State private var showingResetAlert = false
    
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
    
    var body: some View {
        TabView {
            NavigationStack {
                List {
                    // Section En-tête (Stats)
                    Section {
                        VStack(spacing: 30) {
                            StreakFlameView(streak: userStats.currentStreak, isActive: hasWrittenToday)
                                .padding(.vertical, 20)
                                .onTapGesture {
                                    handleFlameTap()
                                }
                            
                            HStack(spacing: 20) {
                                statCard(title: "POINTS", value: "\(userStats.totalPoints)", color: .yellow, icon: "star.fill")
                                statCard(title: "RECORD", value: "\(userStats.longestStreak)j", color: .blue, icon: "trophy.fill")
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                    
                    // Bouton d'écriture
                    Section {
                        Button(action: { showingEditor = true }) {
                            HStack {
                                Image(systemName: hasWrittenToday ? "pencil.and.outline" : "bolt.fill")
                                Text(hasWrittenToday ? "Continuer à écrire" : "Sauver ma série")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(hasWrittenToday ? Color.gray : Color.orange)
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                    }
                    
                    // Section Historique
                    Section(header: Text("VOS RÉCITS").font(.caption.bold())) {
                        if entries.isEmpty {
                            Text("Prêt à écrire ? Vos textes apparaîtront ici.")
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            ForEach(entries) { entry in
                                entryRow(for: entry)
                                    .swipeActions(edge: .trailing) {
                                        if Calendar.current.isDate(entry.date, inSameDayAs: Date()) {
                                            Button(role: .destructive) {
                                                deleteEntry(entry)
                                            } label: {
                                                Label("Supprimer", systemImage: "trash")
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
                .navigationTitle("DuoScribo")
                .background(Color(uiColor: .systemGroupedBackground))
                .sheet(isPresented: $showingEditor) {
                    EditorView(stats: userStats)
                }
                .alert("Réinitialisation complète ?", isPresented: $showingResetAlert) {
                    Button("Annuler", role: .cancel) { resetTapCount = 0 }
                    Button("Tout effacer", role: .destructive) { performFullReset() }
                } message: {
                    Text("Cela va supprimer tous vos textes, vos points et votre série. Cette action est irréversible.")
                }
            }
            .tabItem {
                Label("Écriture", systemImage: "pencil.line")
            }
            
            SocialView()
                .tabItem {
                    Label("Défis", systemImage: "person.2.fill")
                }
        }
        .tint(.orange)
    }
    
    private func handleFlameTap() {
        resetTapCount += 1
        if resetTapCount >= 7 {
            showingResetAlert = true
        }
        
        // Réinitialise le compteur après 2 secondes d'inactivité
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !showingResetAlert {
                resetTapCount = 0
            }
        }
    }
    
    @MainActor
    private func performFullReset() {
        // 1. Supprimer tous les récits
        for entry in entries {
            modelContext.delete(entry)
        }
        
        // 2. Réinitialiser les stats
        userStats.totalPoints = 0
        userStats.currentStreak = 0
        userStats.longestStreak = 0
        userStats.lastWritingDate = nil
        
        resetTapCount = 0
        
        // Feedback haptique de "nettoyage"
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    private func statCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.system(.title2, design: .rounded).bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func entryRow(for entry: WritingEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date, style: .date)
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                Spacer()
                Text("\(entry.wordCount) mots")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(entry.content)
                .lineLimit(3)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
    
    @MainActor
    private func deleteEntry(_ entry: WritingEntry) {
        withAnimation {
            StreakManager.shared.processDeletion(of: entry, in: userStats, allEntries: entries)
            modelContext.delete(entry)
        }
    }
}

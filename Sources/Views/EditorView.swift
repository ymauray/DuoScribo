import SwiftUI
import SwiftData
import AVFoundation

struct EditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var entries: [WritingEntry] // On récupère toutes les entrées pour le calcul global
    
    // Pour les nouveaux textes
    @AppStorage("draft_content") private var draftContent: String = ""
    
    // Pour l'édition
    @State private var content: String = ""
    var stats: UserStats
    var entryToEdit: WritingEntry?
    
    @State private var wordCount: Int = 0
    @FocusState private var isFocused: Bool
    let haptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                wordCounterHeader
                
                TextEditor(text: $content)
                    .font(.custom("Georgia", size: 20))
                    .lineSpacing(8)
                    .padding()
                    .focused($isFocused)
                    .onChange(of: content) { oldValue, newValue in
                        updateWordCount(oldValue: oldValue, newValue: newValue)
                    }
                
                Spacer()
            }
            .navigationTitle(entryToEdit == nil ? "Aujourd'hui" : "Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(entryToEdit == nil ? "Publier" : "Enregistrer") {
                        save()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .bold()
                }
            }
        }
        .onAppear {
            if let entry = entryToEdit {
                content = entry.content ?? ""
            } else {
                content = draftContent
            }
            isFocused = true
            wordCount = countWords(content)
        }
    }
    
    private var wordCounterHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(wordCount)")
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundColor(wordCount > 0 ? .orange : .gray)
                    .contentTransition(.numericText())
                
                Text("mots")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if wordCount >= 250 {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.orange)
                        .transition(.scale)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.1)).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * min(CGFloat(wordCount) / 250.0, 1.0), height: 8)
                        .animation(.spring(), value: wordCount)
                }
            }
            .frame(height: 8)
            
            // Texte de coaching contextuel
            Text(coachingText)
                .font(.caption2.bold())
                .foregroundColor(.orange.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(Color.white)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private var coachingText: String {
        if wordCount < 150 {
            return "OBJECTIF : 150 MOTS (+5 PTS)"
        } else if wordCount < 200 {
            return "OBJECTIF : 200 MOTS (+5 PTS)"
        } else if wordCount < 250 {
            return "OBJECTIF : 250 MOTS (+5 PTS)"
        } else {
            return "GAIN MAXIMUM ATTEINT ! 🏆"
        }
    }
    
    private func updateWordCount(oldValue: String, newValue: String) {
        let newCount = countWords(newValue)
        if newCount != wordCount {
            withAnimation(.spring()) { wordCount = newCount }
            if newCount > 0 && newCount % 10 == 0 && newCount > countWords(oldValue) {
                haptic.impactOccurred()
            }
        }
    }
    
    private func countWords(_ text: String) -> Int {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    @MainActor
    private func save() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.ambient, mode: .default)
        try? audioSession.setActive(true)

        if let entry = entryToEdit {
            entry.content = content
            entry.wordCount = countWords(content)
        } else {
            let entry = WritingEntry(content: content)
            modelContext.insert(entry)
            NotificationManager.shared.cancelReminderForToday()
            draftContent = ""
        }
        
        // On demande un recalcul global basé sur la DB
        // On passe toutes les entrées récupérées par la Query
        // (SwiftData s'assure qu'elles sont à jour)
        StreakManager.shared.updateStats(in: stats, allEntries: entries)
        
        // Son de succès (1407 est souvent plus fiable que 1025)
        AudioServicesPlaySystemSound(1407)
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

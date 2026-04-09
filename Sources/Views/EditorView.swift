import SwiftUI
import SwiftData

struct EditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Sauvegarde automatique du brouillon
    @AppStorage("draft_content") private var content: String = ""
    
    @State private var wordCount: Int = 0
    @FocusState private var isFocused: Bool
    
    var stats: UserStats
    let haptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Compteur de mots animé
                wordCounterHeader
                
                // Éditeur de texte Zen
                TextEditor(text: $content)
                    .font(.custom("Georgia", size: 20)) // Police plus agréable pour l'écriture
                    .lineSpacing(8)
                    .padding()
                    .focused($isFocused)
                    .onChange(of: content) { oldValue, newValue in
                        updateWordCount(oldValue: oldValue, newValue: newValue)
                    }
                
                Spacer()
            }
            .navigationTitle("Aujourd'hui")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publier") {
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
            
            // Jauge de progression (Cap à 250 mots)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * min(CGFloat(wordCount) / 250.0, 1.0), height: 8)
                        .animation(.spring(), value: wordCount)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(Color.white)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func updateWordCount(oldValue: String, newValue: String) {
        let newCount = countWords(newValue)
        if newCount != wordCount {
            withAnimation(.spring()) {
                wordCount = newCount
            }
            // Feedback haptique tous les 10 mots
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
        let entry = WritingEntry(content: content)
        modelContext.insert(entry)
        
        // Mise à jour de la logique de streak
        StreakManager.shared.processNewEntry(entry, in: stats)
        
        // Annuler le rappel pour aujourd'hui
        NotificationManager.shared.cancelReminderForToday()
        
        // Vider le brouillon après publication
        content = ""
        
        // Feedback haptique de succès
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        dismiss()
    }
}

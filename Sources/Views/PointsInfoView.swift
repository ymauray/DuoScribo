import SwiftUI

struct PointsInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Barème des points").font(.caption.bold())) {
                    pointRow(range: "1 à 149 mots", points: "10 pts")
                    pointRow(range: "150 à 199 mots", points: "15 pts")
                    pointRow(range: "200 à 249 mots", points: "20 pts")
                    pointRow(range: "250 mots et +", points: "25 pts", isMax: true)
                }
                
                Section(header: Text("Multiplicateur de série").font(.caption.bold())) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Votre régularité est récompensée !")
                            .font(.headline)
                        
                        Text("Chaque jour de série consécutif ajoute un bonus de **1%** à vos gains du jour.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Exemple : Après 50 jours, vous gagnez **50%** de points en plus sur chaque texte !")
                            .font(.caption)
                            .italic()
                            .padding(.top, 5)
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("Actions rapides").font(.caption.bold())) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Glisser à droite")
                                .font(.headline)
                        }
                        
                        Text("Copie le texte pour le coller où vous voulez.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Divider()
                            .padding(.vertical, 2)
                        
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Glisser à gauche")
                                .font(.headline)
                        }
                        
                        Text("Supprime le texte (uniquement possible le jour même).")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Rappel quotidien", systemImage: "bell.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Un petit rappel vous est envoyé à **21h** si vous n'avez pas encore écrit pour sauver votre série.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Comment ça marche ?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                        .bold()
                }
            }
        }
    }
    
    private func pointRow(range: String, points: String, isMax: Bool = false) -> some View {
        HStack {
            Text(range)
            Spacer()
            Text(points)
                .bold()
                .foregroundColor(isMax ? .orange : .primary)
        }
    }
}

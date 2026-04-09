import SwiftUI

struct SocialView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Défis en cours")) {
                    HStack {
                        Image(systemName: "person.badge.shield.check.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Défier un ami")
                                .font(.headline)
                            Text("Comparez vos séries de jours")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Classement des écrivains")) {
                    HStack {
                        Text("1")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("Vous")
                            .font(.body.bold())
                        Spacer()
                        Text("Score en cours...")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Défis")
        }
    }
}

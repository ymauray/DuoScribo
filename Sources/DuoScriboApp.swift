import SwiftUI
import SwiftData

@main
struct DuoScriboApp: App {
    let container: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(container)
    }
    
    init() {
        do {
            let config = ModelConfiguration(cloudKitDatabase: .automatic)
            container = try ModelContainer(for: WritingEntry.self, UserStats.self, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        NotificationManager.shared.requestAuthorization()
    }
}

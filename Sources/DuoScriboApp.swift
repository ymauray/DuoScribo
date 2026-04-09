import SwiftUI
import SwiftData

@main
struct DuoScriboApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [WritingEntry.self, UserStats.self])
    }
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
}

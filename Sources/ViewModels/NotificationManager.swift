import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Autorisation notifications accordée")
                self.scheduleDailyReminder()
            }
        }
    }
    
    func scheduleDailyReminder() {
        // On nettoie les anciens rappels pour éviter les doublons
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "DuoScribo ✍️"
        content.body = "N'oubliez pas d'écrire quelques mots pour maintenir votre série !"
        content.sound = .default
        
        // Configuration pour 22h00
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelReminderForToday() {
        // Sur iOS, on ne peut pas facilement annuler "juste aujourd'hui" une notification récurrente
        // La stratégie simple : On supprime tout et on reprogramme pour demain
        // Mais pour faire simple et efficace, on va juste supprimer la notification pendante
        // et l'app la reprogrammera intelligemment au prochain lancement ou à l'écriture.
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }
}

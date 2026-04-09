import Foundation
import SwiftData

@MainActor
class StreakManager {
    static let shared = StreakManager()
    
    private init() {}
    
    /// Met à jour les statistiques de l'utilisateur après une nouvelle session d'écriture.
    func processNewEntry(_ entry: WritingEntry, in stats: UserStats) {
        let calendar = Calendar.current
        let today = entry.date
        
        // 1. Gestion de la série (Streak)
        if let lastDate = stats.lastWritingDate {
            if calendar.isDate(lastDate, inSameDayAs: today) || lastDate > today {
                // On a déjà écrit aujourd'hui, on ne touche pas à la streak mais on ajoute des points
            } else {
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
                if calendar.isDate(lastDate, inSameDayAs: yesterday) {
                    stats.currentStreak += 1
                } else {
                    stats.currentStreak = 1
                }
            }
        } else {
            stats.currentStreak = 1
        }
        
        stats.lastWritingDate = today
        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }
        
        // 2. Calcul des Points
        let rawPoints = Double(entry.wordCount) * 0.1
        let roundedPoints = floor(rawPoints / 5.0) * 5.0
        var basePoints = Int(roundedPoints)
        basePoints = max(10, min(25, basePoints))
        
        let multiplier = 1.0 + (Double(stats.currentStreak) / 100.0)
        let xpGained = Int(Double(basePoints) * multiplier)
        
        // On mémorise les points dans l'entrée pour la suppression future
        entry.pointsEarned = xpGained
        stats.totalPoints += xpGained
    }
    
    /// Gère les conséquences de la suppression d'une entrée sur les points et la flamme.
    func processDeletion(of entry: WritingEntry, in stats: UserStats, allEntries: [WritingEntry]) {
        // Retrait des points
        stats.totalPoints = max(0, stats.totalPoints - entry.pointsEarned)
        
        // Mise à jour de la date de dernière écriture
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(entry.date, inSameDayAs: today) {
            // Si c'était un texte d'aujourd'hui, on vérifie s'il en reste d'autres
            let remainingToday = allEntries.filter { 
                $0.id != entry.id && calendar.isDate($0.date, inSameDayAs: today) 
            }
            
            if remainingToday.isEmpty {
                // Plus rien pour aujourd'hui ! La flamme doit s'éteindre.
                // On remonte à la date du texte précédent le plus récent (s'il existe)
                let previousEntries = allEntries.filter { $0.id != entry.id && $0.date < entry.date }
                stats.lastWritingDate = previousEntries.first?.date
                
                // Note: On ne décrémente pas la streak tout de suite, l'utilisateur a jusqu'à minuit
                // pour ré-écrire et sauver sa série.
            }
        }
    }
}

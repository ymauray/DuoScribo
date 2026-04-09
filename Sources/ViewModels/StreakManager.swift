import Foundation
import SwiftData

@MainActor
class StreakManager {
    static let shared = StreakManager()
    
    private init() {}
    
    /// Met à jour les statistiques de l'utilisateur de manière exhaustive.
    func updateStats(in stats: UserStats, allEntries: [WritingEntry]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 1. Calcul de la Série et du Record
        let uniqueDates = allEntries.map { calendar.startOfDay(for: $0.date) }
            .unique()
            .sorted() // Du plus ancien au plus récent pour le calcul du record
        
        var maxStreakFound = 0
        var currentStreakInProgress = 0
        var lastDay: Date?
        
        for date in uniqueDates {
            if let last = lastDay, calendar.dateComponents([.day], from: last, to: date).day == 1 {
                currentStreakInProgress += 1
            } else {
                currentStreakInProgress = 1
            }
            maxStreakFound = max(maxStreakFound, currentStreakInProgress)
            lastDay = date
        }
        
        // Mise à jour du record
        stats.longestStreak = maxStreakFound
        
        // Calcul de la série actuelle (doit finir hier ou aujourd'hui)
        if let mostRecent = uniqueDates.last {
            stats.lastWritingDate = mostRecent
            let diff = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
            if diff <= 1 {
                // On retrouve la streak qui finit à cette date
                var streak = 0
                var check = mostRecent
                let dateSet = Set(uniqueDates)
                while dateSet.contains(check) {
                    streak += 1
                    guard let prev = calendar.date(byAdding: .day, value: -1, to: check) else { break }
                    check = prev
                }
                stats.currentStreak = streak
            } else {
                stats.currentStreak = 0 // Série brisée
            }
        } else {
            stats.currentStreak = 0
            stats.lastWritingDate = nil
        }
        
        // 2. Recalcul total des points
        let entriesByDay = Dictionary(grouping: allEntries) { calendar.startOfDay(for: $0.date) }
        var totalXP = 0
        
        // On repasse sur chaque jour pour calculer l'XP acquise
        for day in uniqueDates {
            let dayEntries = entriesByDay[day] ?? []
            let dailyWords = dayEntries.reduce(0) { $0 + $1.wordCount }
            
            // Règle: 1-149 mots = 10 pts, 150-199 = 15 pts, 200-249 = 20 pts, 250+ = 25 pts
            let rawPoints = Double(dailyWords) * 0.1
            let roundedPoints = floor(rawPoints / 5.0) * 5.0
            var basePoints = Int(roundedPoints)
            basePoints = max(10, min(25, basePoints))
            
            // Multiplicateur à ce moment là
            var streakAtThatDay = 0
            var check = day
            let dateSet = Set(uniqueDates)
            while dateSet.contains(check) {
                streakAtThatDay += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: check) else { break }
                check = prev
            }
            
            let multiplier = 1.0 + (Double(streakAtThatDay) / 100.0)
            let dayXP = Int(Double(basePoints) * multiplier)
            
            totalXP += dayXP
            
            // Mise à jour des entrées pour info
            for entry in dayEntries {
                entry.pointsEarned = dayXP / dayEntries.count
            }
        }
        
        stats.totalPoints = totalXP
    }
    
    func processNewEntry(_ entry: WritingEntry, in stats: UserStats) {}
    func processDeletion(of entry: WritingEntry, in stats: UserStats, allEntries: [WritingEntry]) {}
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        Array(Set(self))
    }
}

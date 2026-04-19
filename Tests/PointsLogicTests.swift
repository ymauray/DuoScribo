import XCTest
import SwiftData
@testable import DuoScribo

@MainActor
final class PointsLogicTests: XCTestCase {
    
    func testDailyCumulativePoints() {
        let stats = UserStats()
        let manager = StreakManager.shared
        let today = Date()
        
        // 1. Premier texte de 100 mots -> 10 pts (min)
        let entry1 = WritingEntry(content: String(repeating: "mot ", count: 100), date: today)
        manager.updateStats(in: stats, allEntries: [entry1])
        
        // Base 10 * 1.01 (streak 1) = 10.1 -> 10 pts
        XCTAssertEqual(stats.totalPoints ?? 0, 10, "100 mots devraient rapporter 10 points")
        
        // 2. Deuxième texte de 100 mots le même jour -> Total 200 mots -> 20 pts
        let entry2 = WritingEntry(content: String(repeating: "mot ", count: 100), date: today)
        manager.updateStats(in: stats, allEntries: [entry1, entry2])
        
        // Base 20 * 1.01 (streak 1) = 20.2 -> 20 pts
        XCTAssertEqual(stats.totalPoints ?? 0, 20, "Le cumul de 200 mots le même jour devrait rapporter 20 points")
        
        // 3. Troisième texte de 100 mots -> Total 300 mots -> Capé à 25 pts
        let entry3 = WritingEntry(content: String(repeating: "mot ", count: 100), date: today)
        manager.updateStats(in: stats, allEntries: [entry1, entry2, entry3])
        
        // Base 25 (cap) * 1.01 = 25.25 -> 25 pts
        XCTAssertEqual(stats.totalPoints ?? 0, 25, "Le cumul au-delà de 250 mots devrait être capé à 25 points bruts")
    }
    
    func testPointsAcrossMultipleDays() {
        let stats = UserStats()
        let manager = StreakManager.shared
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Hier : 250 mots (25 pts bruts)
        let entryYesterday = WritingEntry(content: String(repeating: "mot ", count: 250), date: yesterday)
        
        // Aujourd'hui : 100 mots (10 pts bruts)
        let entryToday = WritingEntry(content: String(repeating: "mot ", count: 100), date: today)
        
        manager.updateStats(in: stats, allEntries: [entryYesterday, entryToday])
        
        // Calcul attendu :
        // Hier: Streak 1. Base 25 * 1.01 = 25 pts
        // Aujourd'hui: Streak 2. Base 10 * 1.02 = 10 pts
        // Total: 25 + 10 = 35 pts
        XCTAssertEqual(stats.currentStreak ?? 0, 2)
        XCTAssertEqual(stats.totalPoints ?? 0, 35, "Le total devrait être la somme des points de chaque jour")
    }
    
    func testFullResetLogic() {
        let stats = UserStats(totalPoints: 100, currentStreak: 5, longestStreak: 5)
        let manager = StreakManager.shared
        
        // Simuler un reset
        manager.updateStats(in: stats, allEntries: [])
        
        XCTAssertEqual(stats.totalPoints ?? 0, 0)
        XCTAssertEqual(stats.currentStreak ?? 0, 0)
        XCTAssertEqual(stats.longestStreak ?? 0, 0, "Le record doit retomber à 0 s'il n'y a plus de textes")
    }
    
    func testEditPointsRecalculation() {
        let stats = UserStats()
        let manager = StreakManager.shared
        let today = Date()
        
        // 1. Un texte court (50 mots -> 10 pts)
        let entry = WritingEntry(content: String(repeating: "mot ", count: 50), date: today)
        manager.updateStats(in: stats, allEntries: [entry])
        XCTAssertEqual(stats.totalPoints ?? 0, 10)
        
        // 2. On modifie ce texte pour qu'il soit long (300 mots -> 25 pts)
        entry.content = String(repeating: "long ", count: 300)
        entry.wordCount = 300
        manager.updateStats(in: stats, allEntries: [entry])
        
        XCTAssertEqual(stats.totalPoints ?? 0, 25, "L'édition du texte doit mettre à jour le score global")
    }
}

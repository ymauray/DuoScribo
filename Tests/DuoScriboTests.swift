import XCTest
import SwiftData
@testable import DuoScribo

@MainActor
final class DuoScriboTests: XCTestCase {
    
    func testStreakAndPoints() {
        let stats = UserStats()
        let manager = StreakManager.shared
        let calendar = Calendar.current
        let today = Date()
        
        // Jour 1 - 50 mots (0.1 * 50 = 5 pts, arrondi à 5, mais min 10)
        let entry1 = WritingEntry(content: String(repeating: "mot ", count: 50), date: today)
        manager.processNewEntry(entry1, in: stats)
        
        XCTAssertEqual(stats.currentStreak, 1)
        // 10 pts base * 1.01 multiplier = 10 pts
        XCTAssertEqual(stats.totalPoints, 10)
        
        // Jour 2 - 151 mots (0.1 * 151 = 15.1 pts, arrondi à 15, max 25)
        let day2 = calendar.date(byAdding: .day, value: 1, to: today)!
        let entry2 = WritingEntry(content: String(repeating: "mot ", count: 151), date: day2)
        manager.processNewEntry(entry2, in: stats)
        
        XCTAssertEqual(stats.currentStreak, 2)
        // 15 pts base * 1.02 multiplier = 15.3 -> 15 pts
        // Total: 10 + 15 = 25
        XCTAssertEqual(stats.totalPoints, 25)
        
        // Jour 3 - 300 mots (0.1 * 300 = 30 pts, capé à 25)
        let day3 = calendar.date(byAdding: .day, value: 2, to: today)!
        let entry3 = WritingEntry(content: String(repeating: "mot ", count: 300), date: day3)
        manager.processNewEntry(entry3, in: stats)
        
        XCTAssertEqual(stats.currentStreak, 3)
        // 25 pts base * 1.03 multiplier = 25.75 -> 25 pts
        // Total: 25 + 25 = 50
        XCTAssertEqual(stats.totalPoints, 50)
    }
}

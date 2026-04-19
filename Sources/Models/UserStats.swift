import Foundation
import SwiftData

@Model
final class UserStats {
    var totalPoints: Int? = 0
    var currentStreak: Int? = 0
    var longestStreak: Int? = 0
    var lastWritingDate: Date? = nil
    
    init(totalPoints: Int = 0, currentStreak: Int = 0, longestStreak: Int = 0) {
        self.totalPoints = totalPoints
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}

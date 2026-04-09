import Foundation
import SwiftData

@Model
final class WritingEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var content: String = ""
    var wordCount: Int = 0
    var pointsEarned: Int = 0
    
    init(content: String, date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.content = content
        self.wordCount = content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
}

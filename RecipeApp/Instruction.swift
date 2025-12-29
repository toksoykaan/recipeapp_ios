import Foundation
import SwiftData

@Model
final class Instruction {
    @Attribute(.unique) var id: UUID
    var stepNumber: Int
    var text: String
    var timerMinutes: Int?
    var imageUrl: String?

    init(
        id: UUID = UUID(),
        stepNumber: Int,
        text: String,
        timerMinutes: Int? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.text = text
        self.timerMinutes = timerMinutes
        self.imageUrl = imageUrl
    }
}

import SwiftData
import Foundation

@Model
final class CycleStats {
    var averageCycleLength: Double
    var averagePeriodLength: Double
    var shortestCycle: Int
    var longestCycle: Int
    var totalCyclesTracked: Int
    var lastUpdated: Date

    init() {
        self.averageCycleLength = 28.0
        self.averagePeriodLength = 5.0
        self.shortestCycle = 28
        self.longestCycle = 28
        self.totalCyclesTracked = 0
        self.lastUpdated = Date()
    }
}

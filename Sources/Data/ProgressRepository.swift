import Foundation

protocol ProgressRepository {
    func saveProgress() async throws
}

struct SwiftDataProgressStore: ProgressRepository {
    func saveProgress() async throws { }
}

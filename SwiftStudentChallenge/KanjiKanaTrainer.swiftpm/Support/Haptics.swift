import UIKit

@MainActor
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func tap()     { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
}

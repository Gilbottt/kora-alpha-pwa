
import Foundation

/// ContextAwareRouter
/// -------------------
/// Maps high-level mode into a tone label.
/// Gives the brain + tone engine a shared contract.
final class ContextAwareRouter {

    static let shared = ContextAwareRouter()

    private init() {}

    func tone(for mode: String) -> String {
        switch mode {
        case "conversation":
            return "warm"
        case "architect":
            return "precise"
        case "code":
            return "technical"
        default:
            return "neutral"
        }
    }
}


import Foundation

/// SmartIntentEngine
/// ------------------
/// Lightweight intent detection for v4.
/// This can be expanded later into full domain routing.
final class SmartIntentEngine {

    static let shared = SmartIntentEngine()

    private init() {}

    func detectMode(from text: String) -> String {
        let lower = text.lowercased()

        if lower.contains("swift") || lower.contains("xcode") || lower.contains("api") {
            return "code"
        }

        if lower.contains("deck") || lower.contains("investor") || lower.contains("valuation") {
            return "architect"
        }

        if lower.contains("how are you") ||
            lower.contains("talk to me") ||
            lower.contains("be honest with me") {
            return "conversation"
        }

        return "default"
    }
}

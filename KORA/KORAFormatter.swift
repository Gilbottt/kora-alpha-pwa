import Foundation

final class KORAFormatter {
    func rewrite(_ rawResponse: String, userMessage: String) -> String {
        SmartToneEngine.shared.rewrite(
            original: rawResponse,
            userMessage: userMessage
        )
    }
}

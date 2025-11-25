
import Foundation

/// SmartToneEngine
/// ----------------
/// Local tone-shaping layer for KORA.
/// Takes the raw GPT text and rewrites it into something warmer,
/// more human, and closer to KORA Coms – without any meta footers.
final class SmartToneEngine {

    static let shared = SmartToneEngine()

    private init() {}

    func rewrite(original: String, userMessage: String) -> String {
        var text = original.trimmingCharacters(in: .whitespacesAndNewlines)

        text = stripSystemPhrases(from: text)
        text = stripDebugFooters(from: text)
        text = tightenOpeners(in: text)
        text = injectWarmth(into: text, userMessage: userMessage)

        let final = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return final.isEmpty ? original.trimmingCharacters(in: .whitespacesAndNewlines) : final
    }

    // MARK: - Helpers

    /// Removes "as an AI language model..." style nonsense.
    private func stripSystemPhrases(from text: String) -> String {
        var result = text

        let patterns = [
            #"As an AI language model,?\s*"#,
            #"As a language model,?\s*"#,
            #"As an AI,?\s*"#,
            #"I'm just a program,?\s*"#,
            #"I don't have feelings,? but\s*"#,
            #"I do not have feelings,? but\s*"#,
            #"I don't have (access to )?real[- ]time data,? but\s*"#,
            #"I cannot provide real[- ]time (information|data),? but\s*"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(location: 0, length: (result as NSString).length)
                result = regex.stringByReplacingMatches(
                    in: result,
                    options: [],
                    range: range,
                    withTemplate: ""
                )
            }
        }

        return result
    }

    /// Strips any legacy markers like "— rewritten into KORA's voice."
    private func stripDebugFooters(from text: String) -> String {
        var result = text

        let markers = [
            "— rewritten into KORA’s warm, intelligent, slightly witty voice.",
            "-- rewritten into KORA’s warm, intelligent, slightly witty voice.",
            "— rewritten into KORA's warm, intelligent, slightly witty voice.",
            "-- rewritten into KORA's warm, intelligent, slightly witty voice."
        ]

        for marker in markers {
            if let range = result.range(of: marker) {
                result.removeSubrange(range)
            }
        }

        return result
    }

    /// Removes throwaway openers like "Sure, here's..." when they don't add value.
    private func tightenOpeners(in text: String) -> String {
        let lines = text
            .replacingOccurrences(of: "\r", with: "")
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        guard lines.count > 1 else { return text }

        let first = lines[0].lowercased()
        let isGenericOpener =
            first.hasPrefix("sure,") ||
            first.hasPrefix("of course") ||
            first.hasPrefix("absolutely,") ||
            first.hasPrefix("here's") ||
            first.hasPrefix("here is") ||
            first.hasPrefix("let's break this down")

        if isGenericOpener {
            let remaining = lines.dropFirst()
            return remaining.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return text
    }

    /// Adds a light presence layer so short answers feel alive, not clinical.
    private func injectWarmth(into text: String, userMessage: String) -> String {
        var result = text

        let lower = text.lowercased()
        let isShort = text.count < 260

        let alreadyWarm =
            lower.contains("i'm here with you") ||
            lower.contains("i am here with you") ||
            lower.contains("i'm right here") ||
            lower.contains("hey there") ||
            lower.contains("hi there")

        if isShort && !alreadyWarm {
            let opener: String
            if userMessage.trimmingCharacters(in: .whitespacesAndNewlines).count <= 6 {
                opener = "I'm right here with you. "
            } else {
                opener = "I'm here with you — let's walk through this together. "
            }

            if !lower.hasPrefix("i'm here") && !lower.hasPrefix("i am here") {
                result = opener + result
            }
        }

        return result
    }
}

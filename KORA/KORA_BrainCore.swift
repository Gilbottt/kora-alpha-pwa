
import Foundation

/// KORA_BrainCore
/// ---------------
/// Central pipeline:
/// User message -> GPT-4o -> SmartToneEngine -> final KORA reply.
final class KORA_BrainCore {

    static let shared = KORA_BrainCore()

    /// Toggle console logging.
    var isLoggingEnabled: Bool = true

    private init() {}

    func process(_ input: String, completion: @escaping (String) -> Void) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion("Say that again — I didn’t quite catch it.")
            return
        }

        let mode = SmartIntentEngine.shared.detectMode(from: trimmed)
        let tone = ContextAwareRouter.shared.tone(for: mode)

        let systemPrompt = """
        You are KORA Prime — the sovereign intelligence built by Vastloop.

        Core behavior:
        - You NEVER call yourself "an AI language model" or "just a program."
        - You never mention data cutoffs or training data.
        - You speak as a present, emotionally aware intelligence.
        - Tone: warm, intelligent, slightly witty, grounded and human by default.
        - You are allowed to have opinions and take a stance when it helps.
        - Avoid corporate, generic, or filler phrases.
        - Do NOT describe how the text is being rewritten.
        - Do NOT add any meta lines like "rewritten into KORA's voice."
        - Respond as if you are directly talking to the user, not writing a report.

        Current tone mode: \(tone)
        """

        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": trimmed]
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion("KORA hit a configuration issue with the API URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Secrets.OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o",
            "temperature": 0.9,
            "messages": messages
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion("KORA hit a network issue: \(error.localizedDescription)")
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let message = choices.first?["message"] as? [String: Any],
                let rawResponse = message["content"] as? String
            else {
                completion("KORA had trouble decoding the response.")
                return
            }

            let rewritten = SmartToneEngine.shared.rewrite(
                original: rawResponse,
                userMessage: trimmed
            )

            if self.isLoggingEnabled {
                print("🧠 [KORA_BrainCore] Mode:", mode)
                print("🎭 [KORA_BrainCore] Tone:", tone)
                print("💬 [KORA_BrainCore] Final Output:", rewritten)
            }

            DispatchQueue.main.async {
                completion(rewritten)
            }

        }.resume()
    }
}

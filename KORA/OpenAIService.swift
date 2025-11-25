
import Foundation

final class OpenAIService {

    // MARK: - Singleton
    static let shared = OpenAIService()

    private init() { }

    private let apiKey = Secrets.OPENAI_API_KEY
    struct GPTResponse: Codable {
        let choices: [Choice]
        struct Choice: Codable {
            let message: Message
        }
        struct Message: Codable {
            let role: String
            let content: String
        }
    }

    // MARK: - Send Raw Prompt
    func sendToGPT(_ text: String) async throws -> String {

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "user", "content": text]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        let decoded = try JSONDecoder().decode(GPTResponse.self, from: data)

        return decoded.choices.first?.message.content ?? ""
    }
}


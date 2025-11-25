
import Foundation
import Combine

final class ChatService: ObservableObject {
    static let shared = ChatService()

    @Published var messages: [ChatMessage] = []
    private let brain = KORA_BrainCore.shared

    private init() {}

    func sendMessage(_ text: String, completion: @escaping (String) -> Void) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion("")
            return
        }

        let userMessage = ChatMessage(role: .user, content: trimmed)
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }

        brain.process(trimmed) { response in
            let assistant = ChatMessage(role: .assistant, content: response)
            DispatchQueue.main.async {
                self.messages.append(assistant)
                completion(response)
            }
        }
    }
}

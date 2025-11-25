import Foundation

final class FallbackHandler {
    static let shared = FallbackHandler()
    private init() {}

    enum FailureKind {
        case network(Error)
        case emptyData
        case badShape
        case decode(Error)
    }

    func recover(from kind: FailureKind, userText: String, completion: @escaping (String) -> Void) {
        let message: String
        switch kind {
        case .network:
            message = "I hit a connection issue. Try again in a moment — or rephrase and I’ll handle it."
        case .emptyData:
            message = "The service returned no data. I can retry or draft a response from context."
        case .badShape:
            message = "I got an unreadable response. I’ll reframe that and try again if you’d like."
        case .decode:
            message = "I couldn’t parse that cleanly. Want a quick, clean summary instead?"
        }
        DispatchQueue.main.async {
            completion(message)
        }
    }
}

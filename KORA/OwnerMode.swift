import Foundation

actor OwnerMode {
    static let shared = OwnerMode()

    private let passphrase = "OLIVIA-14"
    private(set) var isEnabled: Bool = false
    private(set) var lastActivatedAt: Date?

    func handleUserInput(_ text: String) {
        let cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        if cleaned == passphrase {
            isEnabled = true
            lastActivatedAt = Date()
        }
    }

    func disable() {
        isEnabled = false
    }
}

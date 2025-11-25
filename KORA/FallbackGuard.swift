import Foundation

struct FallbackResult {
    let text: String
    let usedFallback: Bool
    let errorDescription: String?
}

actor FallbackGuard {
    static let shared = FallbackGuard()

    func protect(
        _ operationName: String = "chat",
        primary: @escaping () async throws -> String,
        fallback: (() async -> String)? = nil
    ) async -> FallbackResult {
        do {
            let text = try await primary()
            return FallbackResult(text: text, usedFallback: false, errorDescription: nil)
        } catch {
            if let fallback = fallback {
                let text = await fallback()
                return FallbackResult(
                    text: text,
                    usedFallback: true,
                    errorDescription: String(describing: error)
                )
            } else {
                let safe = "KORA hit a snag running \(operationName), but recovered with a safe reply. " +
                           "Ask again if you want to go deeper or adjust the question."
                return FallbackResult(
                    text: safe,
                    usedFallback: true,
                    errorDescription: String(describing: error)
                )
            }
        }
    }
}

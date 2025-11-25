import Foundation

enum BootOptimized {
    static func validateEnvironment() {
        
        let env = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "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"
        if env.isEmpty {
            print("⚠️ OPENAI_API_KEY not found in ENV. Using hardcodedKey if provided.")
        } else {
            print("✅ OPENAI_API_KEY detected in ENV.")
        }
    }
}

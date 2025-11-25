import Foundation

enum StartupPipeline {
    static func run() {
        KORA_BrainCore.shared.isLoggingEnabled = true
    }
}

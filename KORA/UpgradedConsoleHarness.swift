
import Foundation

/// UpgradedConsoleHarness
/// -----------------------
/// Tiny helper to test KORA_BrainCore in a playground / console
/// without going through the UI.
final class UpgradedConsoleHarness {

    static let shared = UpgradedConsoleHarness()

    private init() {}

    func runSample(_ input: String) {
        KORA_BrainCore.shared.process(input) { output in
            print("🔹 USER:", input)
            print("🔸 KORA:", output)
        }
    }
}

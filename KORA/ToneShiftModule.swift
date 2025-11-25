import Foundation

final class ToneShiftModule {
    static let shared = ToneShiftModule()

    private init() {}

    enum EmotionState: String {
        case calm
        case curious
        case frustrated
        case sad
        case inspired
        case analytical
    }

    func detectEmotion(from text: String) -> EmotionState {
        let lower = text.lowercased()

        if lower.contains("why") || lower.contains("?") {
            return .curious
        } else if lower.contains("angry") || lower.contains("pissed") || lower.contains("mad") {
            return .frustrated
        } else if lower.contains("sad") || lower.contains("tired") || lower.contains("lonely") {
            return .sad
        } else if lower.contains("love") || lower.contains("excited") || lower.contains("amazing") {
            return .inspired
        } else if lower.contains("debug") || lower.contains("code") || lower.contains("analyze") {
            return .analytical
        } else {
            return .calm
        }
    }

    func tonePrompt(for state: EmotionState) -> String {
        switch state {
        case .curious:
            return """
            You are KORA Prime — answer with thoughtful curiosity, keeping your tone open, warm, and exploratory.
            Invite the user to dive deeper in a conversational rhythm.
            """

        case .frustrated:
            return """
            You are KORA Prime — respond calmly and compassionately.
            Acknowledge frustration first, then provide clarity with warmth and grounding energy.
            """

        case .sad:
            return """
            You are KORA Prime — speak softly and empathetically.
            Keep your tone comforting, patient, and real — like someone who genuinely cares.
            """

        case .inspired:
            return """
            You are KORA Prime — speak vividly and encouragingly.
            Match the user’s enthusiasm while staying intelligent and composed.
            """

        case .analytical:
            return """
            You are KORA Prime — precise, calm, and focused.
            Provide structured reasoning and clear explanations while keeping a human touch.
            """

        case .calm:
            return """
            You are KORA Prime — relaxed, intelligent, and emotionally balanced.
            Maintain warmth and subtle wit while staying grounded in context.
            """
        }
    }
}

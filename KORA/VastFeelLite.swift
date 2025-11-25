import Foundation

struct VastFeelSnapshot {
    let dominantEmotion: EmotionEstimate
    let recentEmotions: [EmotionEstimate]
}

actor VastFeelLite {
    static let shared = VastFeelLite()

    func currentSnapshot() async -> VastFeelSnapshot {
        let context = await MemoryLoop.shared.recentContext()
        let userSide = context.filter { $0.speaker == .user }

        let emotions = userSide.map { $0.emotion }
        guard !emotions.isEmpty else {
            return VastFeelSnapshot(dominantEmotion: .neutral, recentEmotions: [])
        }

        var counts: [EmotionEstimate: Int] = [:]
        for emotion in emotions {
            counts[emotion, default: 0] += 1
        }

        let dominant = counts.max(by: { $0.value < $1.value })?.key ?? .neutral
        return VastFeelSnapshot(dominantEmotion: dominant, recentEmotions: emotions)
    }
}

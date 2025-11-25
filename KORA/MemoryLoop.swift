import Foundation

enum SpeakerRole {
    case user
    case kora
}

enum EmotionEstimate: String {
    case neutral
    case positive
    case frustrated
    case angry
    case sad
    case anxious
    case excited
}

struct MemoryEntry: Identifiable {
    let id = UUID()
    let speaker: SpeakerRole
    let text: String
    let timestamp: Date
    let emotion: EmotionEstimate
    let topicHash: String?
}

actor MemoryLoop {
    static let shared = MemoryLoop(maxWindowSize: 7)

    private let maxWindowSize: Int
    private var entries: [MemoryEntry] = []
    private var lastUserTopicHash: String?

    init(maxWindowSize: Int = 7) {
        self.maxWindowSize = max(1, maxWindowSize)
    }

    func addUserMessage(_ text: String) {
        let emotion = Self.estimateEmotion(from: text)
        let topicHash = Self.topicSignature(for: text)

        if let lastHash = lastUserTopicHash,
           Self.isTopicShift(from: lastHash, to: topicHash) {
            entries.removeAll()
        }

        lastUserTopicHash = topicHash

        let entry = MemoryEntry(
            speaker: .user,
            text: text,
            timestamp: Date(),
            emotion: emotion,
            topicHash: topicHash
        )
        append(entry)
    }

    func addKoraMessage(_ text: String) {
        let emotion = Self.estimateEmotion(from: text)
        let entry = MemoryEntry(
            speaker: .kora,
            text: text,
            timestamp: Date(),
            emotion: emotion,
            topicHash: nil
        )
        append(entry)
    }

    func recentContext() -> [MemoryEntry] {
        return entries
    }

    func clear() {
        entries.removeAll()
        lastUserTopicHash = nil
    }

    func clearOnUserRequest() {
        clear()
    }

    private func append(_ entry: MemoryEntry) {
        entries.append(entry)

        if entries.count > maxWindowSize {
            let overflow = entries.count - maxWindowSize
            if overflow > 0 {
                entries.removeFirst(overflow)
            }
        }
    }

    // Topic signature based on simple keyword hashing.
    private static func topicSignature(for text: String) -> String {
        let rawTokens = text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty && $0.count > 3 }

        return rawTokens.prefix(5).joined(separator: "|")
    }

    private static func isTopicShift(from old: String, to new: String) -> Bool {
        guard !old.isEmpty, !new.isEmpty else { return false }

        let oldSet = Set(old.split(separator: "|"))
        let newSet = Set(new.split(separator: "|"))

        if oldSet.isEmpty || newSet.isEmpty { return false }

        let intersection = oldSet.intersection(newSet)
        let similarity = Double(intersection.count) / Double(min(oldSet.count, newSet.count))

        return similarity < 0.2
    }

    private static func estimateEmotion(from text: String) -> EmotionEstimate {
        let lower = text.lowercased()

        let frustrationWords = ["fuck", "fucking", "pissed", "annoyed", "irritated", "angry", "wtf"]
        if frustrationWords.contains(where: { lower.contains($0) }) {
            return .frustrated
        }

        let sadWords = ["sad", "down", "tired", "drained", "exhausted", "depressed"]
        if sadWords.contains(where: { lower.contains($0) }) {
            return .sad
        }

        let anxiousWords = ["anxious", "nervous", "worried", "stressed", "overwhelmed"]
        if anxiousWords.contains(where: { lower.contains($0) }) {
            return .anxious
        }

        let positiveWords = ["excited", "hyped", "stoked", "happy", "love this", "fire", "let's go", "lets go"]
        if positiveWords.contains(where: { lower.contains($0) }) {
            return .positive
        }

        let excitedMarkers = ["!!!", "🔥", "crazy", "insane"]
        if excitedMarkers.contains(where: { lower.contains($0) }) {
            return .excited
        }

        return .neutral
    }
}

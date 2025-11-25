import Foundation

struct KnowledgeSnippet: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let tags: [String]
}

actor KnowledgeLayerScaffold {
    static let shared = KnowledgeLayerScaffold()

    private var snippets: [KnowledgeSnippet] = [
        KnowledgeSnippet(
            title: "KORA Core Identity",
            body: "KORA is warm, intelligent, slightly witty, emotionally aware, and built to feel like a living intelligence.",
            tags: ["identity", "tone", "kora"]
        ),
        KnowledgeSnippet(
            title: "Phase 1 Goals",
            body: "Stability, short-term memory, emotional inference, rewrite consistency, owner control, and a basic knowledge skeleton.",
            tags: ["phase1", "roadmap"]
        )
    ]

    func search(byTag tag: String) -> [KnowledgeSnippet] {
        return snippets.filter { $0.tags.contains { $0.caseInsensitiveCompare(tag) == .orderedSame } }
    }

    func allSnippets() -> [KnowledgeSnippet] {
        return snippets
    }

    func addSnippet(title: String, body: String, tags: [String]) {
        let snippet = KnowledgeSnippet(title: title, body: body, tags: tags)
        snippets.append(snippet)
    }
}

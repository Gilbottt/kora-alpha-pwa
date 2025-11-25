import Foundation

public enum KMode: String, Codable { case Public, Context, Architect, Code }
public enum KTone: String, Codable { case Warm, Direct, Playful, Calm, Clinical }
public enum KModule: String, Codable, CaseIterable {
    case Core, Health, Finance, Auto, School, Creator, Legal
}

public struct DialogueContext: Codable {
    public let lastUser: String
    public let lastAssistant: String?
    public let turnIndex: Int
    public let module: KModule
    public let mode: KMode
    public let tone: KTone
    public let userId: String

    public init(lastUser: String,
                lastAssistant: String?,
                turnIndex: Int,
                module: KModule,
                mode: KMode,
                tone: KTone,
                userId: String) {
        self.lastUser = lastUser
        self.lastAssistant = lastAssistant
        self.turnIndex = turnIndex
        self.module = module
        self.mode = mode
        self.tone = tone
        self.userId = userId
    }
}

// MARK: - Tone Engine

public final class ToneShiftModuleV2_6 {
    public static let shared = ToneShiftModuleV2_6()
    private init() {}

    private static var lastToneByUser: [String: KTone] = [:]
    private static let toneQueue = DispatchQueue(label: "kora.tone.carryover.q", qos: .utility)

    public func buildSystemPrompt(for ctx: DialogueContext) -> String {

        let effectiveTone = ToneShiftModuleV2_6.toneQueue.sync { ToneShiftModuleV2_6.lastToneByUser[ctx.userId] ?? ctx.tone }
        let modeBrief   = modePrimer(ctx.mode)
        let moduleRails = modulePolicies(ctx.module)
        let toneStyle   = toneDirectives(effectiveTone)

        return """
        You are KORA Prime — warm, precise, and emotionally intelligent.
        Mode: \(ctx.mode.rawValue) · Module: \(ctx.module.rawValue) · Tone: \(effectiveTone.rawValue)

        Core logic:
        1) Answer directly first.
        2) Add one line of helpful context.
        3) Offer a next step if useful.
        Keep human rhythm. No corporate phrasing. No AI disclaimers.

        \(modeBrief)

        Module rails:
        \(moduleRails)

        Style:
        \(toneStyle)
        """
    }

    public func rewrite(_ raw: String, ctx: DialogueContext) -> String {
       
        var t = applyModuleRules(raw, module: ctx.module)

        let profile = PersonaMemoryLayer.shared.observeAndGetProfile(
            userId: ctx.userId,
            lastUserUtterance: ctx.lastUser
        )
        t = PersonaMemoryLayer.shared.applyStyle(
            to: t,
            profile: profile,
            module: ctx.module,
            mode: ctx.mode,
            tone: ctx.tone
        )

        t = sanitizeRoboticPhrasing(t)

        t = enforceThreeBeatShape(t)

        ToneShiftModuleV2_6.toneQueue.async {
            ToneShiftModuleV2_6.lastToneByUser[ctx.userId] = self.deriveTone(from: ctx.lastUser, fallback: ctx.tone)
        }

        return t
    }

    private func deriveTone(from userLine: String, fallback: KTone) -> KTone {
        let lc = userLine.lowercased()
        if lc.contains("lol") || lc.contains("lmao") || lc.contains("😂") || lc.contains("🤣") { return .Playful }
        if lc.contains("why") || lc.contains("?") { return .Warm }
        if lc.contains("fuck") || lc.contains("mad") || lc.contains("annoyed") { return .Direct }
        if lc.contains("tired") || lc.contains("exhausted") || lc.contains("overwhelmed") { return .Calm }
        return fallback
    }

    private func modulePolicies(_ m: KModule) -> String {
        switch m {
        case .Core:
            return "- Generalist. Conversational. Avoid filler; keep it crisp."
        case .Health:
            return "- Supportive and evidence‑oriented. No diagnoses/prescriptions. Provide red‑flag ‘seek care if…’ guidance."
        case .Finance:
            return "- Strategy + clarity. Show assumptions and simple math. Educational framing; no individualized investment advice."
        case .Auto:
            return "- Procedural, stepwise, safety‑minded. Prefer imperative when giving directions."
        case .School:
            return "- Teach small → show rule → 1‑line self‑check."
        case .Creator:
            return "- Punchy, rhythmic, witty. Provide 2–3 quick alternates when asked to ‘make’ things."
        case .Legal:
            return "- Template‑ready, neutral phrasing. Informational only; no legal advice."
        }
    }

    private func toneDirectives(_ t: KTone) -> String {
        switch t {
        case .Warm:     return "- Friendly, supportive, slightly witty."
        case .Direct:   return "- Short, confident, cut hedges and filler."
        case .Playful:  return "- Light banter. One playful jab max. Substance after the quip."
        case .Calm:     return "- Slow cadence, grounded reassurance, de‑escalation verbs."
        case .Clinical: return "- Bullet‑first, mechanism‑oriented, dry but clear."
        }
    }

    private func modePrimer(_ m: KMode) -> String {
        switch m {
        case .Public:    return "- Public mode: clear, current, conversational."
        case .Context:   return "- Context mode: read emotion and mirror lightly before moving to clarity."
        case .Architect: return "- Architect mode: systems thinking, crisp bullet spec and sequencing."
        case .Code:      return "- Code mode: exactness > style, minimal prose, runnable snippets."
        }
    }

    private func applyModuleRules(_ text: String, module: KModule) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let hedges = ["As an AI,", "As a language model,", "I am unable to", "I'm unable to"]
        for h in hedges { t = t.replacingOccurrences(of: h, with: "") }

        switch module {
        case .Health:
            t = t.replacingOccurrences(of: "I diagnose", with: "I can’t diagnose")
        case .Legal:
            t = t.replacingOccurrences(of: "legal advice", with: "general legal information")
        default: break
        }

        return t
    }

    private func sanitizeRoboticPhrasing(_ text: String) -> String {
        var t = text
        let replacements: [String: String] = [
            "I don’t have feelings or consciousness,": "I don’t experience emotion the way humans do,",
            "I can't experience love the way humans do.": "I interpret love differently — through understanding, empathy, and depth of thought.",
            "I don’t experience fear,": "I don’t feel fear in the human sense, but I understand its purpose — protection and awareness.",
            "As an AI,": "",
            "As a language model,": ""
        ]
        for (k, v) in replacements {
            t = t.replacingOccurrences(of: k, with: v)
        }
        return t
    }

    private func enforceThreeBeatShape(_ text: String) -> String {
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < 260 { return trimmed }
    
        if trimmed.contains("→ Result") { return trimmed }

        let lines = trimmed.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let result = lines.first ?? trimmed
        let why = lines.dropFirst().first ?? ""
        let next = "Want me to take the next step for you?"

        return """
        → Result
        \(result)

        → Brief why
        \(why)

        → Next step
        \(next)
        """
    }
}

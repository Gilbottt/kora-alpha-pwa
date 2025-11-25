import Foundation

final class MemoryLayer {
    static let shared = MemoryLayer()
    private var history: [(role: String, content: String)] = []
    
    func store(role: String, content: String) {
        history.append((role: role, content: content))
        if history.count > 20 { history.removeFirst() }
    }
    
    func recent() -> [(role: String, content: String)] {
        return Array(history.suffix(10))
    }
    
    func clear() {
        history.removeAll()
    }
}

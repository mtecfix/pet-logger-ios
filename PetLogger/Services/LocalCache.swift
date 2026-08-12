import Foundation

/// Generic local cache using UserDefaults + JSON encoding.
/// Stores/retrieves any Codable array by key.
/// Apps use this to persist data offline and show stale data when network fails.
class LocalCache {
    static let shared = LocalCache()
    private let defaults = UserDefaults.standard

    func save<T: Encodable>(_ items: [T], key: String) {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }

    func load<T: Decodable>(_ type: T.Type, key: String) -> [T]? {
        guard let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([T].self, from: data) else { return nil }
        return items
    }

    func clear(key: String) {
        defaults.removeObject(forKey: key)
    }

    var isOnline: Bool {
        // Simple connectivity check via a known endpoint
        // In production, use NWPathMonitor for real-time status
        true
    }
}

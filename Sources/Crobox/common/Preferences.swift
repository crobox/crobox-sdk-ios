import Foundation

/// Values the SDK keeps across app launches
struct Preferences {
    static let visitorIdKey = "com.crobox.sdk.visitorId"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Returns the stored visitor id, creating and storing a new one on first use
    func visitorId() -> UUID {
        if let stored = defaults.string(forKey: Preferences.visitorIdKey),
           let visitorId = UUID(uuidString: stored) {
            return visitorId
        }
        let visitorId = UUID()
        defaults.set(visitorId.uuidString, forKey: Preferences.visitorIdKey)
        return visitorId
    }

    /// Forgets the stored visitor id, so the next call to `visitorId()` creates a new one
    func resetVisitorId() {
        defaults.removeObject(forKey: Preferences.visitorIdKey)
    }
}

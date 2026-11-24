import Foundation

/// The visitor id, stored in `UserDefaults` so that it stays the same across app launches
public enum CroboxVisitor {

    /// Returns the stored visitor id. A new id is created and stored on first use.
    public static func visitorId(defaults: UserDefaults = .standard) -> UUID {
        return Preferences(defaults: defaults).visitorId()
    }

    /// Creates and stores a new visitor id, for example when the user logs out, and returns it.
    /// From then on `visitorId()` returns the new id.
    @discardableResult
    public static func reset(defaults: UserDefaults = .standard) -> UUID {
        return Preferences(defaults: defaults).resetVisitorId()
    }
}

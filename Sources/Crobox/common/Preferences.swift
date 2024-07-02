
import Foundation
struct Preferences {
    static let sharedInstance = Preferences()
    private let defaults = UserDefaults.standard
    private let prefKey = "pref"
}

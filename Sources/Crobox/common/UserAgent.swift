import Foundation

/// The `User-Agent` header the SDK sends: the default iOS user agent, followed by the SDK version, for example
/// `MyShop/42 CFNetwork/1490.0.4 Darwin/23.2.0 CroboxSDK/1.0.33`.
///
/// Setting the header replaces the default one, so the default is rebuilt here. The server derives the OS and
/// OS version from its `CFNetwork/… Darwin/…` part; a bare `CroboxSDK/x.y.z` would tell it nothing about the device.
enum UserAgent {

    static let value: String = build(
        appName: Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ProcessInfo.processInfo.processName,
        appVersion: Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        cfNetworkVersion: Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary?["CFBundleShortVersionString"] as? String,
        darwinVersion: darwinVersion()
    )

    static func build(appName: String?, appVersion: String?, cfNetworkVersion: String?, darwinVersion: String?) -> String {
        var parts: [String] = []
        if let appName, !appName.isEmpty {
            let name = appName.addingPercentEncoding(withAllowedCharacters: productCharacters) ?? appName
            parts.append(appVersion.map { "\(name)/\($0)" } ?? name)
        }
        if let cfNetworkVersion, let darwinVersion {
            parts.append("CFNetwork/\(cfNetworkVersion)")
            parts.append("Darwin/\(darwinVersion)")
        }
        parts.append("CroboxSDK/\(Version.current)")
        return sanitize(parts.joined(separator: " "))
    }

    /// Characters allowed unescaped in a product name, as URLSession's default user agent escapes it (`My%20Shop`).
    private static let productCharacters: CharacterSet = {
        var set = CharacterSet.alphanumerics.intersection(CharacterSet(charactersIn: Unicode.Scalar(0)..<Unicode.Scalar(128)))
        set.insert(charactersIn: "-._~")
        return set
    }()

    /// Header values must be printable ASCII.
    static func sanitize(_ value: String) -> String {
        String(value.unicodeScalars.map { (" "..."~").contains($0) ? Character($0) : "_" })
    }

    /// The kernel release (`23.2.0`), which the default user agent sends as the Darwin version.
    private static func darwinVersion() -> String? {
        var info = utsname()
        guard uname(&info) == 0 else { return nil }
        let release = withUnsafeBytes(of: &info.release) { bytes in
            String(decoding: bytes.prefix(while: { $0 != 0 }), as: UTF8.self)
        }
        return release.isEmpty ? nil : release
    }
}

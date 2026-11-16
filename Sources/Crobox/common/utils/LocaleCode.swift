import Foundation

/**
 The locale of the visitor, in the form `{language}_{COUNTRY}`, for example `en_US`, where
 - the language is the lowercase, two-letter ISO 639-1 language code
 - the country is the uppercase, two-letter ISO 3166-1 country code

 Crobox uses it to select one of the regions configured for your Container, and with it the language, country and
 currency of the request. Use a code that matches one of those regions. When none matches, the Container's
 fallback region is used.

 ```
 LocaleCode("en_US")
 LocaleCode.of(Locale.current)
 ```
 */
public struct LocaleCode: Hashable, CustomStringConvertible, ExpressibleByStringLiteral {

    public let code: String

    public init(_ code: String) {
        self.code = code
    }

    public init(stringLiteral code: String) {
        self.code = code
    }

    /**
     Creates a LocaleCode from a `Locale`, for example `en_US` from `Locale(identifier: "en_US")`, or `en` for a
     locale without a country.
     */
    public static func of(_ locale: Locale) -> LocaleCode {
        let nsLocale = locale as NSLocale
        // Legacy codes for Hebrew, Indonesian and Yiddish
        let language: String
        switch nsLocale.languageCode {
        case "iw": language = "he"
        case "in": language = "id"
        case "ji": language = "yi"
        default: language = nsLocale.languageCode
        }
        guard let country = nsLocale.countryCode, !country.isEmpty else {
            return LocaleCode(language)
        }
        return LocaleCode("\(language)_\(country)")
    }

    public var description: String { code }
}

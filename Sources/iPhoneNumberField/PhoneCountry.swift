//
//  PhoneCountry.swift
//  NeonePhoneNumberField
//

import Foundation
import PhoneNumberKit

/// A country or territory that can be selected in the phone number field's
/// country picker.
///
/// The display name is resolved against the current locale on every read, so
/// `PhoneCountry` values stay stable across language changes and can be
/// compared by `regionCode`.
public struct PhoneCountry: Identifiable, Hashable, Sendable {

    /// ISO 3166-1 alpha-2 region code (e.g. `"US"`, `"GB"`, `"JP"`).
    public let regionCode: String

    /// International calling code (e.g. `1`, `44`, `81`).
    public let callingCode: UInt64

    public init(regionCode: String, callingCode: UInt64) {
        self.regionCode = regionCode
        self.callingCode = callingCode
    }

    public var id: String { regionCode }

    /// The localized country name for display, resolved against the current
    /// locale. Falls back to the raw region code if no localization is
    /// available (e.g. Kosovo, `"XK"`).
    public var displayName: String {
        Locale.current.localizedString(forRegionCode: regionCode) ?? regionCode
    }

    /// The Unicode flag emoji for this region, composed from regional-indicator
    /// symbols. Returns an empty string for region codes that don't map to
    /// real-world flags (e.g. `"001"` for the global code).
    public var flagEmoji: String {
        guard regionCode.count == 2 else { return "" }
        let scalars = regionCode.uppercased().unicodeScalars.compactMap {
            Unicode.Scalar(0x1F1E6 + $0.value - 0x41)
        }
        return String(String.UnicodeScalarView(scalars))
    }
}

extension PhoneCountry: Comparable {
    /// Orders countries alphabetically by their localized display name using
    /// the user's current locale, so the picker always presents a natural
    /// ordering regardless of language.
    public static func < (lhs: PhoneCountry, rhs: PhoneCountry) -> Bool {
        lhs.displayName.localizedStandardCompare(rhs.displayName) == .orderedAscending
    }
}

public extension PhoneCountry {
    /// Every country/region known to `PhoneNumberUtility`, sorted by localized
    /// display name.
    ///
    /// Entries whose region code has no calling-code metadata are skipped.
    static func all() -> [PhoneCountry] {
        let utility = PhoneNumberUtility.shared
        return utility.allCountries()
            .compactMap { region in
                guard let code = utility.countryCode(for: region) else { return nil }
                return PhoneCountry(regionCode: region, callingCode: code)
            }
            .sorted()
    }

    /// The device's current region, or `nil` if it doesn't map to a
    /// `PhoneCountry` (e.g. region has no calling code).
    static var current: PhoneCountry? {
        let region = PhoneNumberUtility.defaultRegionCode()
        guard let code = PhoneNumberUtility.shared.countryCode(for: region) else { return nil }
        return PhoneCountry(regionCode: region, callingCode: code)
    }
}


//
//  PhoneNumberFormatStyle.swift
//  NeonePhoneNumberField
//

import Foundation
import PhoneNumberKit

/// A `ParseableFormatStyle` for phone numbers, backed by `PhoneNumberUtility`.
///
/// Use with `TextField(value:format:)` to bind a `PhoneNumber` directly to a text
/// field without manual validation or `Binding(get:set:)` plumbing:
///
/// ```swift
/// @State private var number: PhoneNumber?
///
/// TextField("Phone", value: $number, format: .phoneNumber(region: "US"))
/// ```
///
/// Parse failures leave the bound value unchanged and revert the displayed text
/// on commit, matching the behavior of Foundation's built-in format styles.
public struct PhoneNumberFormatStyle: ParseableFormatStyle, Sendable, Hashable, Codable {

    /// The region used to interpret input numbers that lack a country code, and
    /// as context for national-format output. ISO 3166-1 alpha-2 (e.g. `"US"`).
    public var region: String

    /// Which canonical representation `format(_:)` should produce.
    public var output: PhoneNumberFormat

    public init(
        region: String = PhoneNumberUtility.defaultRegionCode(),
        output: PhoneNumberFormat = .e164
    ) {
        self.region = region
        self.output = output
    }

    public func format(_ value: PhoneNumber) -> String {
        PhoneNumberUtility.shared.format(value, toType: output)
    }

    public var parseStrategy: PhoneNumberParseStrategy {
        PhoneNumberParseStrategy(region: region)
    }
}

public extension PhoneNumberFormatStyle {
    /// Returns a copy of the style with its output type set to E.164 (`+15551234567`).
    func e164() -> Self { var copy = self; copy.output = .e164; return copy }

    /// Returns a copy of the style with its output type set to international
    /// (`+1 555-123-4567`).
    func international() -> Self { var copy = self; copy.output = .international; return copy }

    /// Returns a copy of the style with its output type set to national
    /// (`(555) 123-4567`).
    func national() -> Self { var copy = self; copy.output = .national; return copy }
}

/// The companion `ParseStrategy` for `PhoneNumberFormatStyle`. Parses a user-
/// entered string into a `PhoneNumber` using `PhoneNumberUtility`.
public struct PhoneNumberParseStrategy: ParseStrategy, Sendable, Hashable, Codable {

    /// The region used to interpret numbers without an explicit country code.
    public var region: String

    public init(region: String = PhoneNumberUtility.defaultRegionCode()) {
        self.region = region
    }

    public func parse(_ value: String) throws -> PhoneNumber {
        try PhoneNumberUtility.shared.parse(value, withRegion: region, ignoreType: false)
    }
}

// MARK: - FormatStyle convenience

public extension FormatStyle where Self == PhoneNumberFormatStyle {
    /// Formats phone numbers using the given region and output format.
    static func phoneNumber(
        region: String = PhoneNumberUtility.defaultRegionCode(),
        output: PhoneNumberFormat = .e164
    ) -> Self {
        PhoneNumberFormatStyle(region: region, output: output)
    }
}

// MARK: - Shared utility

private extension PhoneNumberUtility {
    /// A process-wide `PhoneNumberUtility` instance. Metadata is loaded from
    /// disk on first access, which is expensive; subsequent calls reuse the
    /// cached instance.
    ///
    /// Marked `nonisolated(unsafe)` because the utility holds only read-only
    /// metadata after initialization and is safe to call concurrently from any
    /// isolation domain. PhoneNumberKit is widely used server-side where
    /// concurrent reads are a core use case.
    nonisolated(unsafe) static let shared = PhoneNumberUtility()
}

//
//  PhoneNumberFormatStyleTests.swift
//  NeonePhoneNumberField
//

import Testing
import Foundation
@testable import iPhoneNumberField
import PhoneNumberKit

@Suite("PhoneNumberFormatStyle")
struct PhoneNumberFormatStyleTests {

    // Fixtures: verified valid numbers per region.
    static let fixtures: [(region: String, input: String, e164: String)] = [
        ("US", "(415) 555-1234", "+14155551234"),
        ("GB", "020 7946 0958", "+442079460958"),
        ("FR", "01 42 34 56 78", "+33142345678"),
        ("JP", "03-1234-5678", "+81312345678"),
        ("DE", "030 12345678", "+493012345678"),
    ]

    // MARK: - Format

    @Test("Format produces E.164 canonical output", arguments: fixtures)
    func formatE164(fixture: (region: String, input: String, e164: String)) throws {
        let style = PhoneNumberFormatStyle(region: fixture.region, output: .e164)
        let parsed = try style.parseStrategy.parse(fixture.input)
        #expect(style.format(parsed) == fixture.e164)
    }

    @Test("Format output modes are distinct for the same number")
    func formatModesDiffer() throws {
        let style = PhoneNumberFormatStyle(region: "US")
        let parsed = try style.parseStrategy.parse("+14155551234")
        let e164 = style.e164().format(parsed)
        let intl = style.international().format(parsed)
        let national = style.national().format(parsed)

        #expect(e164 == "+14155551234")
        #expect(intl != e164)     // international has separators
        #expect(national != e164) // national has no country code
        #expect(national != intl) // and differs from international
    }

    // MARK: - Parse

    @Test("Parse accepts a variety of user-typed formats")
    func parseVariations() throws {
        let style = PhoneNumberFormatStyle(region: "US")
        let variants = [
            "+1 (415) 555-1234",
            "+1-415-555-1234",
            "14155551234",
            "415.555.1234",
            "(415) 555 1234",
        ]
        for input in variants {
            let parsed = try style.parseStrategy.parse(input)
            #expect(style.format(parsed) == "+14155551234", "variant '\(input)' did not produce the expected E.164")
        }
    }

    @Test("Parse throws on clearly invalid input")
    func parseRejectsInvalid() {
        let style = PhoneNumberFormatStyle(region: "US")
        #expect(throws: (any Error).self) {
            _ = try style.parseStrategy.parse("not a phone number")
        }
        #expect(throws: (any Error).self) {
            _ = try style.parseStrategy.parse("123")
        }
    }

    // MARK: - Round-trip

    @Test("parse(format(x)) == x", arguments: fixtures)
    func roundTrip(fixture: (region: String, input: String, e164: String)) throws {
        let style = PhoneNumberFormatStyle(region: fixture.region, output: .e164)
        let parsed = try style.parseStrategy.parse(fixture.input)
        let formatted = style.format(parsed)
        let reparsed = try style.parseStrategy.parse(formatted)
        #expect(parsed == reparsed)
    }

    // MARK: - Region boundary

    @Test("Parsing a US number from a GB context still recovers the US number")
    func regionBoundary() throws {
        let gbStyle = PhoneNumberFormatStyle(region: "GB")
        // A US number given with its country code should parse under any region.
        let parsed = try gbStyle.parseStrategy.parse("+1 (415) 555-1234")
        #expect(gbStyle.format(parsed) == "+14155551234")
    }

    // MARK: - PartialFormatter

    @Test("PartialFormatter output grows correctly as digits are typed")
    func partialFormatterGrowth() {
        let formatter = PartialFormatter(utility: .shared, defaultRegion: "US")
        let sequence = ["4", "41", "415", "4155", "41555", "415555", "4155551", "41555512", "415555123", "4155551234"]

        // Each step should be a non-empty string and the final step should
        // contain all the typed digits.
        for step in sequence {
            let out = formatter.formatPartial(step)
            #expect(!out.isEmpty, "PartialFormatter returned empty for '\(step)'")
        }
        let final = formatter.formatPartial("4155551234")
        #expect(final.filter(\.isNumber) == "4155551234")
    }

    // MARK: - FormatStyle convenience

    @Test("static .phoneNumber(region:) produces the same style as the explicit init")
    func staticFactory() {
        let explicit = PhoneNumberFormatStyle(region: "US", output: .national)
        let viaFactory: PhoneNumberFormatStyle = .phoneNumber(region: "US", output: .national)
        #expect(explicit == viaFactory)
    }

    // MARK: - Sendable / value semantics

    @Test("Mutating a copy does not affect the original")
    func valueSemantics() {
        let original = PhoneNumberFormatStyle(region: "US", output: .e164)
        let mutated = original.national()
        #expect(original.output == .e164)
        #expect(mutated.output == .national)
        #expect(original.region == mutated.region)
    }
}

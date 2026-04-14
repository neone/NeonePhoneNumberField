//
//  PhoneField.swift
//  NeonePhoneNumberField
//

import SwiftUI
import PhoneNumberKit

/// A pure-SwiftUI phone number entry field. Formats input as the user types
/// using `PhoneNumberKit.PartialFormatter`, supports iOS SMS autofill via
/// `.textContentType(.telephoneNumber)`, and presents a searchable country
/// picker when the flag is tapped.
///
/// Example:
/// ```swift
/// @State private var phoneNumber: String = ""
///
/// PhoneField("Phone", text: $phoneNumber)
/// ```
@MainActor
public struct PhoneField: View {

    @Binding private var text: String
    @State private var country: PhoneCountry
    @State private var showPicker = false

    private let placeholder: LocalizedStringKey
    private let showFlag: Bool
    private let selectableFlag: Bool
    private let showPrefix: Bool
    private let onPhoneNumberChange: (PhoneNumber?) -> Void

    /// Creates a phone number field bound to a `String` value.
    /// - Parameters:
    ///   - placeholder: The field's placeholder text.
    ///   - text: A binding to the formatted phone number string. As the user
    ///     types, this is rewritten with the partial-format output.
    ///   - country: The initial selected country. Defaults to the device's
    ///     current region, falling back to `"US"`.
    ///   - showFlag: Whether to show the leading flag. Default `true`.
    ///   - selectableFlag: Whether tapping the flag opens the country picker
    ///     sheet. Default `true`.
    ///   - showPrefix: Whether to show the `+callingCode` next to the flag.
    ///     Default `true`.
    ///   - onPhoneNumberChange: Called after each edit with the parsed
    ///     `PhoneNumber`, or `nil` if the current text does not parse.
    public init(
        _ placeholder: LocalizedStringKey = "Phone",
        text: Binding<String>,
        country: PhoneCountry? = nil,
        showFlag: Bool = true,
        selectableFlag: Bool = true,
        showPrefix: Bool = true,
        onPhoneNumberChange: @escaping (PhoneNumber?) -> Void = { _ in }
    ) {
        self._text = text
        let resolvedCountry = country
            ?? PhoneCountry.current
            ?? PhoneCountry(regionCode: "US", callingCode: 1)
        self._country = State(initialValue: resolvedCountry)
        self.placeholder = placeholder
        self.showFlag = showFlag
        self.selectableFlag = selectableFlag
        self.showPrefix = showPrefix
        self.onPhoneNumberChange = onPhoneNumberChange
    }

    public var body: some View {
        HStack(spacing: 8) {
            if showFlag {
                PhoneFieldFlagButton(
                    country: country,
                    showPrefix: showPrefix,
                    selectable: selectableFlag,
                    action: { showPicker = true }
                )
            }

            TextField(placeholder, text: $text)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .onChange(of: text) { _, newValue in
                    reformat(newValue)
                }
                .onChange(of: country) { _, _ in
                    reformat(text)
                }
        }
        .sheet(isPresented: $showPicker) {
            PhoneCountryPicker(selection: $country)
        }
    }

    private func reformat(_ input: String) {
        let formatter = PartialFormatter(
            utility: .shared,
            defaultRegion: country.regionCode
        )
        let formatted = formatter.formatPartial(input)
        if formatted != text {
            text = formatted
        }
        let parsed = try? PhoneNumberUtility.shared.parse(
            formatted,
            withRegion: country.regionCode,
            ignoreType: false
        )
        onPhoneNumberChange(parsed)
    }
}

private struct PhoneFieldFlagButton: View {
    let country: PhoneCountry
    let showPrefix: Bool
    let selectable: Bool
    let action: () -> Void

    var body: some View {
        if selectable {
            Button(action: action) {
                label
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select country")
            .accessibilityValue(country.displayName)
        } else {
            label
                .accessibilityLabel(country.displayName)
        }
    }

    private var label: some View {
        HStack(spacing: 4) {
            Text(country.flagEmoji)
                .accessibilityHidden(true)
            if showPrefix {
                Text("+\(country.callingCode)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

#Preview {
    PhoneFieldPreview()
}

private struct PhoneFieldPreview: View {
    @State private var text = ""
    @State private var parsed: PhoneNumber?

    var body: some View {
        Form {
            Section {
                PhoneField("Phone number", text: $text) { parsed = $0 }
            }
            Section("Parsed") {
                Text(parsed.map { PhoneNumberUtility.shared.format($0, toType: .e164) } ?? "—")
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}

//
//  PhoneCountryPicker.swift
//  NeonePhoneNumberField
//

import SwiftUI

/// A searchable list of every country/region known to `PhoneNumberUtility`.
///
/// Typically presented from `PhoneField` as a sheet when the user taps the
/// flag/prefix button, but usable anywhere a country selection UI is needed.
public struct PhoneCountryPicker: View {

    @Binding private var selection: PhoneCountry
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private let countries: [PhoneCountry]

    public init(selection: Binding<PhoneCountry>) {
        self._selection = selection
        self.countries = PhoneCountry.all()
    }

    public var body: some View {
        NavigationStack {
            List(filteredCountries) { country in
                Button {
                    selection = country
                    dismiss()
                } label: {
                    PhoneCountryRow(country: country, isSelected: country == selection)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .navigationTitle("Select country")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search country")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
            }
        }
    }

    private var filteredCountries: [PhoneCountry] {
        guard !query.isEmpty else { return countries }
        return countries.filter { country in
            country.displayName.localizedStandardContains(query)
                || country.regionCode.localizedStandardContains(query)
                || String(country.callingCode).contains(query)
        }
    }
}

private struct PhoneCountryRow: View {
    let country: PhoneCountry
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(country.flagEmoji)
                .font(.title3)
                .accessibilityHidden(true)

            Text(country.displayName)

            Spacer()

            Text("+\(country.callingCode)")
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Image(systemName: "checkmark")
                .foregroundStyle(.tint)
                .opacity(isSelected ? 1 : 0)
                .accessibilityHidden(!isSelected)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(country.displayName), +\(country.callingCode)")
        .accessibilityValue(isSelected ? "Selected" : "")
    }
}

#Preview {
    @Previewable @State var selection = PhoneCountry.current ?? PhoneCountry(regionCode: "US", callingCode: 1)

    PhoneCountryPicker(selection: $selection)
}

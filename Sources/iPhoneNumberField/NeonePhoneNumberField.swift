//
//  NeonePhoneNumberField.swift
//  NeonePhoneNumberField
//
//  Backward-compatible deprecation shim for the UIViewRepresentable-based
//  iPhoneNumberField type. Forwards to the pure-SwiftUI `PhoneField`.
//
//  This shim will be removed in v3.0. New code should use `PhoneField`.
//

import SwiftUI

/// Deprecated: use ``PhoneField`` instead.
///
/// This type exists only to preserve source compatibility for consumers of the
/// original `iPhoneNumberField` API. It delegates to ``PhoneField`` and will be
/// removed in a future major version.
@available(*, deprecated, renamed: "PhoneField", message: "Use PhoneField. iPhoneNumberField will be removed in v3.0.")
public struct iPhoneNumberField: View {

    @Binding private var text: String
    private let placeholder: String?
    private var showFlag: Bool = true
    private var selectableFlag: Bool = true
    private var showPrefix: Bool = true

    public init(_ placeholder: String? = nil, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        PhoneField(
            placeholder.map { LocalizedStringKey($0) } ?? "Phone",
            text: $text,
            showFlag: showFlag,
            selectableFlag: selectableFlag,
            showPrefix: showPrefix
        )
    }

    /// Deprecated: pass `showFlag:` to ``PhoneField`` directly.
    public func flagHidden(_ hidden: Bool) -> Self {
        var copy = self
        copy.showFlag = !hidden
        return copy
    }

    /// Deprecated: pass `selectableFlag:` to ``PhoneField`` directly.
    public func flagSelectable(_ selectable: Bool) -> Self {
        var copy = self
        copy.selectableFlag = selectable
        return copy
    }

    /// Deprecated: pass `showPrefix:` to ``PhoneField`` directly.
    public func prefixHidden(_ hidden: Bool) -> Self {
        var copy = self
        copy.showPrefix = !hidden
        return copy
    }
}

//
//  UIFont+Init.swift
//  iPhoneNumberField
//

import UIKit

public extension UIFont {
    /// Initializes a `UIFont` using the same system initializer syntax available in SwiftUI `Font`.
    /// - Parameters:
    ///   - size: The font size as a `CGFloat`.
    ///   - weight: Font weight from the `UIFont.Weight` types.
    ///   - design: Font design from the `UIFontDescriptor.SystemDesign` options.
    /// - Returns: The initialized font, or `nil` if the system cannot produce a descriptor
    ///   for the requested combination.
    convenience init?(
        size: CGFloat = 14,
        weight: UIFont.Weight = .regular,
        design: UIFontDescriptor.SystemDesign = .rounded
    ) {
        guard let descriptor = UIFont.systemFont(ofSize: size, weight: weight)
            .fontDescriptor
            .withDesign(design) else {
            return nil
        }
        self.init(descriptor: descriptor, size: size)
    }
}

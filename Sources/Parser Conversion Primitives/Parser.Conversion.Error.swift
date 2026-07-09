//
//  Parser.Conversion.Error.swift
//  swift-parser-primitives
//
//  Shared failure for partial conversion combinators.
//

extension Parser.Conversion {
    /// The failure raised by the partial conversion combinators.
    ///
    /// Total conversions (``Parser/Conversion/Identity``,
    /// ``Parser/Conversion/Memberwise``) use `Never`; the partial combinators
    /// (``Parser/Conversion/RawValue``, ``Parser/Conversion/Fixed``) raise a
    /// case of this error. Payload-free so it stays Embedded-friendly.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// ``Parser/Conversion/RawValue`` received a raw value with no
        /// corresponding `RawRepresentable` case.
        case unrepresentable

        /// ``Parser/Conversion/Fixed`` received an output during `unapply` that
        /// did not equal the expected constant value.
        case mismatch
    }
}

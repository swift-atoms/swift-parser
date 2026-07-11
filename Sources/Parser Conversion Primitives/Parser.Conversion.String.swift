//
//  Parser.Conversion.String.swift
//  swift-parser-primitives
//
//  Substring ⇆ String conversion.
//

extension Parser.Conversion {
    /// A total conversion between `Substring` and `String`.
    ///
    /// The forward direction copies the `Substring` into a fresh `String`; the
    /// reverse direction wraps the `String` back into a `Substring`. Both
    /// directions are total (`Failure == Never`) — every `Substring` has a
    /// `String` form and every `String` a `Substring` form.
    ///
    /// This is the printer-friendly way to lift a `Substring`-producing parser
    /// to a `String`-producing one: parsing copies out a `String`, printing
    /// wraps it back into the `Substring` the upstream parser consumes, so a
    /// bidirectional upstream stays bidirectional through `.map(.string)`.
    ///
    /// ```swift
    /// // Prefix.While { … }.map(.string)  — Substring -> String
    /// ```
    ///
    /// Created via ``Parser/Conversion/Protocol/string``.
    public struct String {
        /// Creates a `Substring` ⇆ `String` conversion.
        @inlinable
        public init() {}
    }
}

extension Parser.Conversion.String: Parser.Conversion.`Protocol` {
    /// This conversion converts from a `Substring`.
    public typealias Input = Substring
    /// This conversion converts to a `String`.
    public typealias Output = Swift.String
    /// This conversion is total.
    public typealias Failure = Never

    /// Copies the substring into a fresh string.
    @inlinable
    public func apply(_ input: Substring) -> Swift.String {
        Swift.String(input)
    }

    /// Wraps the string back into a substring.
    @inlinable
    public func unapply(_ output: Swift.String) -> Substring {
        Substring(output)
    }
}

extension Parser.Conversion.`Protocol` where Self == Parser.Conversion.String {
    /// A total conversion between `Substring` and `String`.
    ///
    /// ```swift
    /// parser.map(.string)  // Substring -> String, printer-preserving
    /// ```
    @inlinable
    public static var string: Self { .init() }
}

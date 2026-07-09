//
//  Parser.Conversion.RawValue.swift
//  swift-parser-primitives
//
//  Raw value ⇆ RawRepresentable conversion.
//

extension Parser.Conversion {
    /// A conversion from a raw value to a `RawRepresentable` type and back.
    ///
    /// The forward direction is the failable `init?(rawValue:)`; the reverse is
    /// the total `rawValue` accessor. Useful for lifting the output of a
    /// primitive parser-printer (a `String`, an `Int`) into a domain wrapper
    /// while preserving printability.
    ///
    /// ```swift
    /// struct Tag: RawRepresentable { var rawValue: Int; init(rawValue: Int) { self.rawValue = rawValue } }
    ///
    /// let tag = intParser.map(.representing(Tag.self))   // Int -> Tag
    /// ```
    ///
    /// Created via ``Parser/Conversion/Protocol/representing(_:)``.
    public struct RawValue<Output: RawRepresentable> {
        /// Creates a raw-value conversion.
        @inlinable
        public init() {}
    }
}

extension Parser.Conversion.RawValue: Parser.Conversion.`Protocol` {
    /// The raw value this conversion converts from.
    public typealias Input = Output.RawValue
    /// Partial: `apply` fails when the raw value has no representable case.
    public typealias Failure = Parser.Conversion.Error

    /// Builds the `RawRepresentable` value from its raw value.
    ///
    /// - Throws: ``Parser/Conversion/Error/unrepresentable`` when the raw value
    ///   has no corresponding case.
    @inlinable
    public func apply(_ input: Output.RawValue) throws(Parser.Conversion.Error) -> Output {
        guard let output = Output(rawValue: input) else {
            throw .unrepresentable
        }
        return output
    }

    /// Returns the underlying raw value.
    @inlinable
    public func unapply(_ output: Output) -> Output.RawValue {
        output.rawValue
    }
}

extension Parser.Conversion.`Protocol` {
    /// A conversion from a raw value to the given `RawRepresentable` type.
    ///
    /// - Parameter type: A `RawRepresentable` type.
    /// - Returns: A conversion from `type.RawValue` to `type`.
    @inlinable
    public static func representing<Output>(
        _ type: Output.Type
    ) -> Self where Self == Parser.Conversion.RawValue<Output> {
        .init()
    }
}

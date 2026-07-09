//
//  Parser.Conversion.Identity.swift
//  swift-parser-primitives
//
//  The no-op conversion.
//

extension Parser.Conversion {
    /// A conversion that returns its input unchanged in both directions.
    ///
    /// The identity element of ``Parser/Conversion/Map`` composition. Useful as
    /// a default conversion or to satisfy a generic conversion parameter without
    /// changing the value.
    ///
    /// Created via ``Parser/Conversion/Protocol/identity()``.
    public struct Identity<Value> {
        /// Creates an identity conversion.
        @inlinable
        public init() {}
    }
}

extension Parser.Conversion.Identity: Parser.Conversion.`Protocol` {
    /// The type this conversion converts from.
    public typealias Input = Value
    /// The type this conversion converts to.
    public typealias Output = Value
    /// This conversion is total.
    public typealias Failure = Never

    /// Returns the input unchanged.
    @inlinable
    public func apply(_ input: Value) -> Value { input }

    /// Returns the output unchanged.
    @inlinable
    public func unapply(_ output: Value) -> Value { output }
}

extension Parser.Conversion.`Protocol` {
    /// A conversion that returns its value unchanged in both directions.
    ///
    /// ```swift
    /// parser.map(.identity())
    /// ```
    @inlinable
    public static func identity<Value>() -> Self
    where Self == Parser.Conversion.Identity<Value> {
        .init()
    }
}

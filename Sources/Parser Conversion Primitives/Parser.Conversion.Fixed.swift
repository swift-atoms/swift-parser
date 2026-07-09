//
//  Parser.Conversion.Fixed.swift
//  swift-parser-primitives
//
//  Void ⇆ constant-value conversion.
//

extension Parser.Conversion {
    /// A conversion between `Void` and a fixed constant value.
    ///
    /// The forward direction injects the constant; the reverse direction
    /// verifies that the output equals the constant and erases it to `Void`.
    /// This is the printer-friendly way to attach a constant to a `Void`-output
    /// parser (a matched literal): parsing yields the constant, printing checks
    /// the value and re-prints the literal.
    ///
    /// ```swift
    /// // "GET".map(.fixed(HTTP.Method.get))  — Void -> HTTP.Method.get
    /// ```
    ///
    /// Created via ``Parser/Conversion/Protocol/fixed(_:)``.
    public struct Fixed<Output: Equatable> {
        @usableFromInline
        internal let value: Output

        /// Creates a conversion that injects and verifies the given constant.
        @inlinable
        public init(_ value: Output) {
            self.value = value
        }
    }
}

extension Parser.Conversion.Fixed: Parser.Conversion.`Protocol` {
    /// This conversion converts from `Void`.
    public typealias Input = Void
    /// Partial: `unapply` fails when the output does not match the constant.
    public typealias Failure = Parser.Conversion.Error

    /// Returns the constant value, ignoring the `Void` input.
    @inlinable
    public func apply(_ input: Void) -> Output { value }

    /// Verifies the output equals the constant, erasing it to `Void`.
    ///
    /// - Throws: ``Parser/Conversion/Error/mismatch`` when the output differs
    ///   from the constant.
    @inlinable
    public func unapply(_ output: Output) throws(Parser.Conversion.Error) {
        guard output == value else {
            throw .mismatch
        }
    }
}

extension Parser.Conversion.`Protocol` {
    /// A conversion between `Void` and the given constant value.
    ///
    /// - Parameter value: The constant to inject on `apply` and verify on `unapply`.
    /// - Returns: A conversion from `Void` to the constant's type.
    @inlinable
    public static func fixed<Output>(
        _ value: Output
    ) -> Self where Self == Parser.Conversion.Fixed<Output> {
        .init(value)
    }
}

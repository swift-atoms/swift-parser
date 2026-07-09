//
//  Parser.Conversion.Protocol.swift
//  swift-parser-primitives
//
//  Core Conversion protocol definition.
//

extension Parser.Conversion {
    /// A type that transforms an `Input` value into an `Output` value and back.
    ///
    /// A conversion is the printability-preserving counterpart to a plain
    /// output transform. Where `parser.map { transform($0) }` produces a
    /// parse-only parser, `parser.map(conversion)` produces a parser-printer:
    /// parsing applies ``apply(_:)`` forward, printing applies ``unapply(_:)``
    /// in reverse.
    ///
    /// ## Round-Trip Guarantee
    ///
    /// A well-formed conversion satisfies:
    /// ```
    /// unapply(apply(input))  == input   // for every representable input
    /// apply(unapply(output)) == output  // for every representable output
    /// ```
    ///
    /// ## Typed Throws
    ///
    /// Both directions use typed throws with a shared `Failure` associated
    /// type, defaulting to `Never` for total conversions. Partial conversions
    /// (a raw value with no representable case, a constant that does not match)
    /// override `Failure` to a domain error.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct SubstringToString: Parser.Conversion.Protocol {
    ///     func apply(_ input: Substring) -> String { String(input) }
    ///     func unapply(_ output: String) -> Substring { Substring(output) }
    /// }
    /// ```
    public protocol `Protocol`<Input, Output> {
        /// The type this conversion converts from.
        associatedtype Input

        /// The type this conversion converts to.
        associatedtype Output

        /// The error type either direction can throw.
        ///
        /// Defaults to `Never` for total conversions.
        associatedtype Failure: Swift.Error = Never

        /// Transforms an input into an output.
        ///
        /// The forward direction, run while parsing. See ``unapply(_:)`` for the
        /// reverse.
        ///
        /// - Parameter input: An input value.
        /// - Returns: The transformed output value.
        /// - Throws: `Failure` if the input has no representable output.
        func apply(_ input: Input) throws(Failure) -> Output

        /// Transforms an output back into an input.
        ///
        /// The reverse direction, run while printing. The inverse of
        /// ``apply(_:)``.
        ///
        /// - Parameter output: An output value.
        /// - Returns: The un-transformed input value.
        /// - Throws: `Failure` if the output has no representable input.
        func unapply(_ output: Output) throws(Failure) -> Input
    }
}

//
//  Parser.Conversion.Witness.swift
//  swift-parser-primitives
//
//  Closure-backed conversion — the canonical witness for Conversion.Protocol.
//

extension Parser.Conversion {
    /// A closure-backed conversion — the canonical witness for
    /// ``Parser/Conversion/Protocol``.
    ///
    /// `Witness` stores an `apply`/`unapply` closure pair and exposes them as
    /// the protocol requirements. It is the general escape hatch: any
    /// bidirectional transform that has no dedicated combinator can be
    /// expressed as a `Witness`, including case-path style embed/extract pairs
    /// supplied from outside the package.
    ///
    /// ```swift
    /// let celsiusToFahrenheit = Parser.Conversion.Witness<Double, Double, Never>(
    ///     apply: { $0 * 9 / 5 + 32 },
    ///     unapply: { ($0 - 32) * 5 / 9 }
    /// )
    /// ```
    ///
    /// ## Storage
    ///
    /// `_apply` / `_unapply` are `public` so `@inlinable` methods can inline
    /// through. The underscore signals "implementation hatch — call
    /// ``apply(_:)`` / ``unapply(_:)`` rather than the closures directly."
    public struct Witness<Input, Output, Failure: Swift.Error> {
        /// The stored forward closure.
        public var _apply: (Input) throws(Failure) -> Output

        /// The stored reverse closure.
        public var _unapply: (Output) throws(Failure) -> Input

        /// Creates a conversion witness from a forward/reverse closure pair.
        ///
        /// - Parameters:
        ///   - apply: Transforms an input into an output.
        ///   - unapply: Transforms an output back into an input.
        @inlinable
        public init(
            apply: @escaping (Input) throws(Failure) -> Output,
            unapply: @escaping (Output) throws(Failure) -> Input
        ) {
            self._apply = apply
            self._unapply = unapply
        }
    }
}

extension Parser.Conversion.Witness: Parser.Conversion.`Protocol` {
    /// Applies the stored forward closure.
    @inlinable
    public func apply(_ input: Input) throws(Failure) -> Output {
        try _apply(input)
    }

    /// Applies the stored reverse closure.
    @inlinable
    public func unapply(_ output: Output) throws(Failure) -> Input {
        try _unapply(output)
    }
}

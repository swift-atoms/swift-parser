//
//  Parser.Optionally.swift
//  swift-standards
//
//  Runtime optional parser (backtracks on failure).
//

public import Input_Primitives

extension Parser {
    /// A parser that tries to parse but succeeds with nil on failure.
    ///
    /// Unlike `Optional` (compile-time optional), this is runtime optional.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let optionalSign = Parser.Optionally { Sign() }
    /// ```
    public struct Optionally<Wrapped: Parser.`Protocol`>
    where Wrapped.Input: Input_Primitives.Input.`Protocol` {
        @usableFromInline
        internal let wrapped: Wrapped

        /// Creates a parser that backtracks and yields nil when the wrapped parser fails.
        @inlinable
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}

extension Parser.Optionally: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = Wrapped.Input
    /// The output type this parser produces: the wrapped output, or nil on failure.
    public typealias Output = Wrapped.Output?
    /// This parser is infallible.
    public typealias Failure = Never

    // on Property.Inout accessor chains (input.restore.to) in multiple control flow paths.
    /// Parses using the wrapped parser, backtracking and returning nil on failure.
    @inlinable
    public func parse(_ input: inout Input) -> Output {
        let checkpoint = input.checkpoint
        do throws(Wrapped.Failure) {
            return try wrapped.parse(&input)
        } catch {
            input.restore.to(__unchecked: (), checkpoint)
            return nil
        }
    }
}

//
//  Parser.Lazy.swift
//  swift-standards
//
//  Lazy parser for recursive grammars.
//

extension Parser {
    /// A parser that defers construction until parse time.
    ///
    /// `Lazy` enables recursive grammars by breaking the cycle in type
    /// definitions. The parser is built fresh on each `parse` call.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Recursive expression parser
    /// func makeExpr() -> some Parser<Substring, Expr, some Error> {
    ///     OneOf {
    ///         number
    ///         Take {
    ///             "("
    ///             Lazy { makeExpr() }  // Recursive reference
    ///             ")"
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## HTML/XML Parsing
    ///
    /// ```swift
    /// func makeElement() -> some Parser<Substring, Element, some Error> {
    ///     Take {
    ///         "<"
    ///         tagName
    ///         ">"
    ///         Many { Lazy { makeElement() } }  // Nested elements
    ///         "</"
    ///         tagName
    ///         ">"
    ///     }
    /// }
    /// ```
    ///
    /// ## Performance Note
    ///
    /// The closure is called on every `parse` invocation, creating a
    /// new parser instance each time. For hot paths, consider caching
    /// the parser externally if profiling shows this as a bottleneck.
    public struct Lazy<P: Parser.`Protocol`> {
        @usableFromInline
        internal let build: () -> P

        /// Creates a lazy parser from an autoclosure.
        ///
        /// - Parameter build: An expression that creates the parser.
        @inlinable
        public init(_ build: @escaping @autoclosure () -> P) {
            self.build = build
        }

        /// Creates a lazy parser from a closure.
        ///
        /// - Parameter build: A closure that creates the parser.
        @inlinable
        public init(_ build: @escaping () -> P) {
            self.build = build
        }
    }
}

// MARK: - Parser Conformance

extension Parser.Lazy: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = P.Input
    /// The output type this parser produces.
    public typealias Output = P.Output
    /// The error type this parser can throw.
    public typealias Failure = P.Failure

    /// Builds a fresh parser from the stored closure, then parses with it.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try build().parse(&input)
    }
}

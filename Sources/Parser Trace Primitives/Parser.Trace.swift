//
//  Parser.Trace.swift
//  swift-standards
//
//  Debug tracing combinator.
//

extension Parser {
    /// A parser that logs entry, exit, and errors for debugging.
    ///
    /// `Trace` wraps any parser and outputs debug information
    /// without affecting parsing behavior.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let parser = myComplexParser.trace("complex")
    /// // Logs:
    /// // [complex] enter
    /// // [complex] success: <output>
    /// // or
    /// // [complex] failure: <error>
    /// ```
    ///
    /// ## Custom Logger
    ///
    /// ```swift
    /// var logs: [String] = []
    /// let parser = myParser.trace("test") { logs.append($0) }
    /// ```
    public struct Trace<Upstream: Parser.`Protocol`> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let label: String

        @usableFromInline
        let log: (String) -> Void

        /// Creates a tracing parser.
        ///
        /// - Parameters:
        ///   - upstream: The parser to trace.
        ///   - label: Label to identify this parser in logs.
        ///   - log: Logging function. Defaults to `print`.
        @inlinable
        public init(
            _ upstream: Upstream,
            label: String,
            log: @escaping (String) -> Void = { print($0) }
        ) {
            self.upstream = upstream
            self.label = label
            self.log = log
        }
    }
}

// MARK: - Parser Conformance

extension Parser.Trace: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = Upstream.Input
    /// The output type this parser produces, unchanged from the upstream parser.
    public typealias Output = Upstream.Output
    /// The error type this parser can throw, unchanged from the upstream parser.
    public typealias Failure = Upstream.Failure

    /// Parses using the upstream parser, logging entry, success, and failure events.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        log("[\(label)] enter")
        do throws(Upstream.Failure) {
            let result = try upstream.parse(&input)
            log("[\(label)] success: \(result)")
            return result
        } catch {
            log("[\(label)] failure: \(error)")
            throw error
        }
    }
}

// MARK: - Parser Extension

extension Parser.`Protocol` {
    /// Wraps this parser with debug tracing.
    ///
    /// Logs entry, success, and failure events to help debug
    /// complex parser compositions.
    ///
    /// - Parameters:
    ///   - label: Identifier for this parser in logs.
    ///   - log: Optional custom logging function.
    /// - Returns: A tracing wrapper around this parser.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let parser = Take {
    ///     identifier.trace("id")
    ///     "=".trace("equals")
    ///     value.trace("value")
    /// }
    /// ```
    @inlinable
    public func trace(
        _ label: String,
        log: @escaping (String) -> Void = { print($0) }
    ) -> Parser.Trace<Self> {
        Parser.Trace(self, label: label, log: log)
    }
}

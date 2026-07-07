//
//  Parser.First.Element.swift
//  swift-standards
//
//  Parse first element unconditionally.
//

public import Input_Primitives

extension Parser.First {
    /// A parser that consumes and returns the first element.
    ///
    /// Fails if the input is empty.
    ///
    /// This parser only requires `Streaming` capability (no backtracking),
    /// making it suitable for forward-only input sources.
    public struct Element<Input: Input_Primitives.Input.Streaming>
    where Input.Element: Copyable {
        /// Creates a parser that consumes the first element.
        @inlinable
        public init() {}
    }
}

extension Parser.First.Element: Parser.`Protocol` {
    /// The output type this parser produces: the input's element type.
    public typealias Output = Input.Element
    /// The error type this parser can throw when the input is empty.
    public typealias Failure = Parser.EndOfInput.Error

    /// Consumes and returns the first element, failing when the input is empty.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard !input.isEmpty else {
            throw .unexpected(expected: "any element")
        }
        // SAFETY: isEmpty returned false, so advance() cannot throw .empty
        // swift-format-ignore: NeverUseForceTry
        // swiftlint:disable:next force_try
        return try! input.advance()
    }
}

// MARK: - Printer Conformance

extension Parser.First.Element: Parser.Printer
where Input: RangeReplaceableCollection {
    /// Prints the element by inserting it at the front of the input.
    @inlinable
    public func print(_ output: Input.Element, into input: inout Input) {
        input.insert(output, at: input.startIndex)
    }
}

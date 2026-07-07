//
//  Parser.Prefix.UpTo.swift
//  swift-parser-primitives
//
//  Prefix parser that consumes up to (not including) delimiter.
//

public import Collection_Primitives

extension Parser.Prefix {
    /// A parser that consumes up to (but not including) a delimiter sequence.
    ///
    /// Unlike `While`, this looks for a specific delimiter sequence rather
    /// than testing each element.
    public struct UpTo<Input: Collection.Slice.`Protocol`>
    // Element: Copyable is structural (the delimiter is stored as an Array)
    // and stated explicitly: on toolchains where Equatable is generalized
    // to ~Copyable it no longer follows from Equatable.
    where Input.Element: Equatable, Input.Element: Copyable {
        @usableFromInline
        let delimiter: [Input.Element]

        /// Creates a parser consuming input up to the given delimiter sequence.
        @inlinable
        public init(_ delimiter: [Input.Element]) {
            self.delimiter = delimiter
        }
    }
}

extension Parser.Prefix.UpTo: Parser.`Protocol` {
    /// The output type this parser produces: the consumed prefix.
    public typealias Output = Input
    /// This parser is infallible.
    public typealias Failure = Never

    /// Consumes input up to, but not including, the delimiter sequence.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        var endIndex = input.startIndex

        outer: while endIndex < input.endIndex {
            // Check if delimiter starts here
            var checkIndex = endIndex
            for element in delimiter {
                guard checkIndex < input.endIndex else {
                    break outer
                }
                guard input[checkIndex] == element else {
                    // No match, advance and continue
                    input.formIndex(after: &endIndex)
                    continue outer
                }
                input.formIndex(after: &checkIndex)
            }
            // Found delimiter
            break
        }

        let result = input[input.startIndex..<endIndex]
        input = input[endIndex...]
        return result
    }
}

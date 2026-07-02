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

        @inlinable
        public init(_ delimiter: [Input.Element]) {
            self.delimiter = delimiter
        }
    }
}

extension Parser.Prefix.UpTo: Parser.`Protocol` {
    public typealias Output = Input
    public typealias Failure = Never

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

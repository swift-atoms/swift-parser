extension Swift.Slice where Base.Element: Equatable {
    /// Matches a collection literal, committing consumption only after a complete match.
    public struct Parser<Input: Swift.Collection>: Parser::Parsing
    where Input.SubSequence == Input, Input.Element == Base.Element {
        public typealias Output = Void
        public typealias Failure = Error
        public enum Error: Swift.Error, Equatable { case mismatch }

        public let wrapped: Swift.Slice<Base>

        @inlinable
        public init(_ wrapped: Swift.Slice<Base>) { self.wrapped = wrapped }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Error) {
            var end = input.startIndex
            for element in wrapped {
                guard end != input.endIndex, input[end] == element else { throw .mismatch }
                input.formIndex(after: &end)
            }
            input = input[end...]
        }
    }
}

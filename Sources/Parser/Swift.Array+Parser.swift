extension Swift.Array where Element: Equatable {
    /// Matches the supplied literal without consuming input on failure.
    public struct Parser<Input: Swift.Collection>: Parser::Parsing
    where Input.SubSequence == Input, Input.Element == Element {
        public typealias Output = Void
        public typealias Failure = Error

        public enum Error: Swift.Error, Equatable { case mismatch }

        public let wrapped: Swift.Array<Element>

        @inlinable
        public init(_ wrapped: Swift.Array<Element>) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Error) {
            guard matchPrefix(wrapped, in: &input) else { throw .mismatch }
        }
    }
}

extension Parser::Builder
where Input: Swift.Collection, Input.SubSequence == Input, Input.Element: Equatable {
    @inlinable
    public static func buildExpression(_ literal: Swift.Array<Input.Element>) -> Swift.Array<Input.Element>.Parser<Input> {
        .init(literal)
    }
}

@usableFromInline
internal func matchPrefix<Input: Swift.Collection, Expected: Swift.Collection>(
    _ expected: Expected,
    in input: inout Input
) -> Bool
where Input.SubSequence == Input, Input.Element: Equatable, Input.Element == Expected.Element {
    var end = input.startIndex
    for element in expected {
        guard end != input.endIndex, input[end] == element else { return false }
        input.formIndex(after: &end)
    }
    input = input[end...]
    return true
}

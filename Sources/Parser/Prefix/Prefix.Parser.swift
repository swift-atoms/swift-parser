#if Prefix
public import Prefix

extension Prefix {
    /// Selects a prefix and commits input consumption only after selection succeeds.
    public struct Parser<Input: Swift.Collection>: Parser::Parsing
    where Input.SubSequence == Input {
        public typealias Output = Input
        public typealias Failure = Prefix.Error
        public let wrapped: Prefix

        public init(_ wrapped: Prefix) { self.wrapped = wrapped }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Input {
            let end = try wrapped.end(from: input.startIndex) { position in
                position == input.endIndex ? nil : input.index(after: position)
            }
            let output = input[..<end]
            input = input[end...]
            return output
        }
    }
}

extension Parser::Builder where Input: Swift.Collection, Input.SubSequence == Input {
    public static func buildExpression(_ selection: Prefix) -> Prefix.Parser<Input> {
        .init(selection)
    }
}

#endif

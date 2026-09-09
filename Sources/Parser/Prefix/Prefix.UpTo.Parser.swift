#if Prefix
public import Prefix

extension Prefix.UpTo where Delimiter: Swift.Collection, Delimiter.Element: Equatable {
    /// Selects a prefix and commits input consumption only after selection succeeds.
    public struct Parser<Input: Swift.Collection>: Parser::Parsing
    where Input.SubSequence == Input, Input.Element == Delimiter.Element {
        public typealias Output = Input
        public typealias Failure = Prefix.UpTo<Delimiter>.Error
        public let wrapped: Prefix.UpTo<Delimiter>

        public init(_ wrapped: Prefix.UpTo<Delimiter>) { self.wrapped = wrapped }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Input {
            let end = try wrapped.end(from: input.startIndex, advance: { position in
                position == input.endIndex ? nil : input.index(after: position)
            }, matching: { delimiter, position in
                var end = position
                for element in delimiter {
                    guard end != input.endIndex, input[end] == element else { return nil }
                    input.formIndex(after: &end)
                }
                return end
            })
            let output = input[..<end]
            input = input[end...]
            return output
        }
    }
}

extension Parser::Builder where Input: Swift.Collection, Input.SubSequence == Input {
    public static func buildExpression<D: Swift.Collection>(_ selection: Prefix.UpTo<D>) -> Prefix.UpTo<D>.Parser<Input>
    where D.Element: Equatable, D.Element == Input.Element {
        .init(selection)
    }
}

#endif

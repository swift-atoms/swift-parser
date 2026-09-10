#if Repetition && Collection
public import Cardinal
public import Repetition
public import Collection

extension Cardinal.Range {
    public func parser<
        Input: Swift.Collection
    >(
        for input: Input.Type
    ) -> Parser::Parser<
        Input,
        Input,
        Repetition<Self, Void>.Error
    >
    where Input.SubSequence == Input {
        Parser::Parser { input throws(Repetition<Self, Void>.Error) in
            let end = try self.end(in: input)
            let output = input[..<end]
            input = input[end..<input.endIndex]
            return output
        }
    }
}
#endif

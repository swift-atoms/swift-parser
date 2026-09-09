#if Repetition && Collection
public import Cardinal
public import Repetition
public import Collection

extension Cardinal.Range {
    public func parser<Input: Collection.Slice.`Protocol`>(forCollection input: Input.Type) -> Parser::Parser<Input, Input, Repetition<Self, Void>.Error>
    where Input.Element: ~Copyable {
        Parser::Parser { input throws(Repetition<Self, Void>.Error) in
            let end = try self.end(inCollection: input)
            let output = input[input.startIndex..<end]
            input = input[end..<input.endIndex]
            return output
        }
    }
}
#endif

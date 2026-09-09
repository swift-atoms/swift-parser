#if Repetition && Predicate && Collection
public import Cardinal
public import Repetition
public import Predicate
public import Collection

extension Repetition where Bounds: Cardinal.Range {
    public func parser<Input: Collection.Slice.`Protocol`>(forCollection input: Input.Type) -> Parser::Parser<Input, Input, Repetition<Bounds, Void>.Error>
    where Input.Element: ~Copyable, Operation == Predicate<Input.Element> {
        Parser::Parser { input throws(Repetition<Bounds, Void>.Error) in
            let end = try self.end(inCollection: input)
            let output = input[input.startIndex..<end]
            input = input[end..<input.endIndex]
            return output
        }
    }
}
#endif

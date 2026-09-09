#if Repetition && Predicate && Collection
public import Cardinal
public import Repetition
public import Predicate
public import Collection

extension Repetition where Bounds: Cardinal.Range {
    public func parser<Input: Swift.Collection>(for input: Input.Type) -> Parser::Parser<Input, Input, Repetition<Bounds, Void>.Error>
    where Input.SubSequence == Input, Operation == Predicate<Input.Element> {
        Parser::Parser { input throws(Repetition<Bounds, Void>.Error) in
            let end = try self.end(in: input)
            let output = input[..<end]
            input = input[end..<input.endIndex]
            return output
        }
    }
}
#endif

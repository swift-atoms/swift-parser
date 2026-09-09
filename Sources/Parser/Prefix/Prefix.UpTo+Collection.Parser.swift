#if Prefix && Collection
public import Prefix
public import Collection

extension Prefix.UpTo {
    /// Selects before committing, preserving input on selection failure.
    public func parser<Input: Collection.Slice.`Protocol`>(
        forCollection input: Input.Type
    ) -> Parser::Parser<Input, Input, Error> where Input.Element == Delimiter.Element {
        Parser::Parser { input throws(Error) in
            let end = try self.end(inCollection: input)
            let output = input[input.startIndex..<end]
            let remainder = input[end..<input.endIndex]
            input = remainder
            return output
        }
    }
}

#endif

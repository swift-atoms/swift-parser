#if Prefix && Collection
public import Prefix
public import Collection

extension Prefix {
    /// Selects before committing, preserving input on selection failure.
    public func parser<Input: Collection.Slice.`Protocol`>(
        forCollection input: Input.Type
    ) -> Parser::Parser<Input, Input, Prefix.Error> where Input.Element: ~Copyable {
        Parser::Parser { input throws(Prefix.Error) in
            let end = try self.end(inCollection: input)
            let output = input[input.startIndex..<end]
            let remainder = input[end..<input.endIndex]
            input = remainder
            return output
        }
    }
}

#endif

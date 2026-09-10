#if Search && Collection
public import Search
public import Collection

extension Search.Selection where Pattern: Swift.Collection, Pattern.Element: Equatable {

    public func parser<Input: Collection.Slice.`Protocol`>(
        forCollection input: Input.Type
    ) -> Parser::Parser<Input, Input, Error> where Input.Element == Pattern.Element {
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

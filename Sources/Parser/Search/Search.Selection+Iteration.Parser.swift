#if Search && Iterator && Either
public import Search
public import Iterator
public import Either

extension Search.Selection where Pattern: Swift.Collection, Pattern.Element: Equatable {

    public func parser<I: Iterating & ~Copyable & ~Escapable>(
        for input: Iterator::Iterator.Buffered<I, I.Failure>.Type
    ) -> Parser::Parser<Iterator::Iterator.Buffered<I, I.Failure>, [I.Element], Either<Error, I.Failure>>
    where I.Element: Copyable & Escapable, I.Element == Pattern.Element {
        Parser::Parser { input throws(Either<Error, I.Failure>) in
            var output: [I.Element] = []
            try self.forEach(in: &input) { output.append($0) }
            return output
        }
    }
}

#endif

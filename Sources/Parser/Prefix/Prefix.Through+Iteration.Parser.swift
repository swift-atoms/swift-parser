#if Prefix && Iterator && Either
public import Prefix
public import Iterator
public import Either

extension Prefix.Through {
    /// Materializes iterator output. On failure, already delivered output is consumed;
    /// predicate/delimiter lookahead remains in the input wrapper.
    public func parser<I: Iterating & ~Copyable & ~Escapable>(
        for input: Prefix.Iterator<I, I.Failure>.Type
    ) -> Parser::Parser<Prefix.Iterator<I, I.Failure>, [I.Element], Either<Error, I.Failure>>
    where I.Element: Copyable & Escapable, I.Element == Delimiter.Element {
        Parser::Parser { input throws(Either<Error, I.Failure>) in
            var output: [I.Element] = []
            try self.forEach(in: &input) { output.append($0) }
            return output
        }
    }
}

#endif

#if Repetition && Iterator
public import Cardinal
public import Repetition
public import Iterator
public import Either

extension Cardinal.Range {
    public func parser<I: Iterating & ~Copyable & ~Escapable>(for input: Iterator::Iterator.Buffered<I, I.Failure>.Type) -> Parser::Parser<Iterator::Iterator.Buffered<I, I.Failure>, [I.Element], Either<Repetition<Self, Void>.Error, I.Failure>>
    where I.Element: Copyable & Escapable {
        Parser::Parser { input throws(Either<Repetition<Self, Void>.Error, I.Failure>) in
            var output: [I.Element] = []
            try self.forEach(in: &input) { output.append($0) }
            return output
        }
    }
}
#endif

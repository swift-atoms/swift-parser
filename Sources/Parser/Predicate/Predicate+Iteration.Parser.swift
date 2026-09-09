#if Predicate && Iterator && Either
public import Predicate
public import Iterator
public import Either

extension Predicate where T: ~Copyable & ~Escapable {
    /// Reads one element from a forward iterator and tests it by borrowing.
    /// A rejected element has been consumed. Use a restorable input and an
    /// explicit backtracking operation when failure must restore the source.
    public func parser<I: Iterating & ~Copyable & ~Escapable>(
        for input: I.Type
    ) -> Parser::Parser<I, T, Either<Error, I.Failure>>
    where I.Element == T, I.Element: ~Copyable & ~Escapable {
        Parser::Parser { input throws(Either<Error, I.Failure>) in
            let next: T?
            do throws(I.Failure) {
                next = try input.next()
            } catch { throw .right(error) }
            guard let element = consume next else { throw .left(.empty) }
            guard self(element) else { throw .left(.rejected) }
            return element
        }
    }
}

#endif

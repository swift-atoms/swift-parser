#if Lazy
public import Lazy
public import Either

extension Parser::Builder where Input: ~Copyable & ~Escapable {
    @inlinable
    public static func buildExpression<P: Parser::Parsing & ~Copyable>(
        _ lazy: Lazy::Lazy<P, Never>
    ) -> Lazy::Lazy<P, Never>.Parser<P.Failure>
    where P.Input == Input, P.Input: ~Copyable & ~Escapable,
          P.Output: ~Copyable & Escapable {
        .init(lazy)
    }

    @inlinable
    public static func buildExpression<P: Parser::Parsing & ~Copyable, F: Swift.Error>(
        _ lazy: Lazy::Lazy<P, F>
    ) -> Lazy::Lazy<P, F>.Parser<Either<F, P.Failure>>
    where P.Input == Input, P.Input: ~Copyable & ~Escapable,
          P.Output: ~Copyable & Escapable {
        .init(lazy)
    }
}
#endif

#if Lazy
public import Lazy

extension Parser::Builder where Input: ~Copyable & ~Escapable {
    @inlinable
    public static func buildExpression<P: Parser::Parsing>(
        _ lazy: Lazy::Lazy<P>
    ) -> Lazy::Lazy<P>.Parser
    where P.Input == Input, P.Input: ~Copyable & ~Escapable,
          P.Output: ~Copyable & Escapable {
        .init(lazy)
    }
}
#endif

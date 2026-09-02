public import Parser

extension Parser {

    public enum Error {}
}

extension Parser.Error {

    public struct Transform<Upstream: Parser.`Protocol`>
    where
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable
    {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        package init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.`Protocol`
where
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    @inlinable
    public var error: Parser.Error.Transform<Self> {
        Parser.Error.Transform(self)
    }
}

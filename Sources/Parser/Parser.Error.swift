extension Parser {

    public enum Error {}
}

extension Parser.Error {

    public struct Transform<Upstream: Parser.`Protocol` & ~Copyable>: ~Copyable
    where
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable
    {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        public init(_ upstream: consuming Upstream) {
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

extension Parser.Error.Transform: Copyable
where
    Upstream: Parser.`Protocol`<Upstream.Input, Upstream.Output, Upstream.Failure> & Copyable,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable
{}

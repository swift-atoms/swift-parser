extension Parser {

    public enum Error {}
}

extension Parser.Error {

    public struct Transform<Upstream: Parser.`Protocol`> {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        package init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.`Protocol` {

    @inlinable
    public var error: Parser.Error.Transform<Self> {
        Parser.Error.Transform(self)
    }
}

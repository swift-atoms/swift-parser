public import Input

extension Parser {

    public struct Not<Upstream: Parser.`Protocol`>
    where Upstream.Input: __ParserInput.`Protocol` {
        @usableFromInline
        internal let upstream: Upstream

        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.Not {

    public enum Error: Swift.Error, Sendable, Hashable {

        case unexpectedMatch
    }
}

extension Parser.Not: Parser.`Protocol` {

    public typealias Input = Upstream.Input

    public typealias Output = Void

    public typealias Failure = Parser.Not<Upstream>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        let checkpoint = input.checkpoint

        if (try? upstream.parse(&input)) != nil {

            input.seek(to: checkpoint)
            throw .unexpectedMatch
        } else {

            input.seek(to: checkpoint)
        }
    }
}

extension Parser.`Protocol` where Input: __ParserInput.`Protocol` {

    @inlinable
    public func not() -> Parser.Not<Self> {
        Parser.Not(self)
    }
}

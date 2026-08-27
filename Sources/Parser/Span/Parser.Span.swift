public import Input

extension Parser {

    public struct Span<Base: __ParserInput.`Protocol`, Upstream: Parser.`Protocol`>
    where Upstream.Input == Base {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.Span: Parser.`Protocol` {

    public typealias Input = Parser.Tracked<Base>

    public typealias Output = Parser.Spanned<Upstream.Output>

    public typealias Failure = Parser.Error.Located<Upstream.Failure>

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let (value, start) = try input.parseTracked(upstream)
        return Parser.Spanned(value, start: start, end: input.currentOffset)
    }
}

extension Parser.`Protocol` where Input: __ParserInput.`Protocol` & Copyable {

    @inlinable
    public func spanned() -> Parser.Span<Input, Self> {
        Parser.Span(self)
    }
}

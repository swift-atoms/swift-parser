public import Input_Primitives

extension Parser {

    public struct Locate<Base: Input_Primitives.Input.`Protocol`, Upstream: Parser.`Protocol`>
    where Upstream.Input == Base {
        @usableFromInline
        let upstream: Upstream

        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.Locate: Parser.`Protocol` {

    public typealias Input = Parser.Tracked<Base>

    public typealias Output = Upstream.Output

    public typealias Failure = Parser.Error.Located<Upstream.Failure>

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try input.parseTracked(upstream).output
    }
}

extension Parser.`Protocol` where Input: Input_Primitives.Input.`Protocol` & Copyable {

    @inlinable
    public func located() -> Parser.Locate<Input, Self> {
        Parser.Locate(self)
    }
}

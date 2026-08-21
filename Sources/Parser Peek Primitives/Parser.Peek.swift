public import Input_Primitives

extension Parser {

    public struct Peek<Upstream: Parser.`Protocol`>
    where Upstream.Input: Input_Primitives.Input.`Protocol` {
        @usableFromInline
        internal let upstream: Upstream

        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.Peek: Parser.`Protocol` {

    public typealias Input = Upstream.Input

    public typealias Output = Upstream.Output

    public typealias Failure = Upstream.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let checkpoint = input.checkpoint
        do throws(Upstream.Failure) {
            let result = try upstream.parse(&input)
            input.restore.to(__unchecked: (), checkpoint)
            return result
        } catch {
            input.restore.to(__unchecked: (), checkpoint)
            throw error
        }
    }
}

extension Parser.`Protocol` where Input: Input_Primitives.Input.`Protocol` {

    @inlinable
    public func peek() -> Parser.Peek<Self> {
        Parser.Peek(self)
    }
}

public import Input

extension Parser.OneOf {

    public struct Three<P0: Parser.`Protocol`, P1: Parser.`Protocol`, P2: Parser.`Protocol`>
    where
        P0.Input == P1.Input,
        P1.Input == P2.Input,
        P0.Output == P1.Output,
        P1.Output == P2.Output,
        P0.Input: __ParserInput.`Protocol`
    {

        public let p0: P0

        public let p1: P1

        public let p2: P2

        @inlinable
        public init(_ p0: P0, _ p1: P1, _ p2: P2) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
        }
    }
}

extension Parser.OneOf.Three {

    public struct Error: Swift.Error {

        public let first: P0.Failure

        public let second: P1.Failure

        public let third: P2.Failure

        @inlinable
        public init(_ first: P0.Failure, _ second: P1.Failure, _ third: P2.Failure) {
            self.first = first
            self.second = second
            self.third = third
        }
    }
}

extension Parser.OneOf.Three: Parser.`Protocol` {

    public typealias Input = P0.Input

    public typealias Output = P0.Output

    public typealias Failure = Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let checkpoint = input.checkpoint

        do throws(P0.Failure) { return try p0.parse(&input) } catch let error0 {
            input.seek(to: checkpoint)
            do throws(P1.Failure) { return try p1.parse(&input) } catch let error1 {
                input.seek(to: checkpoint)
                do throws(P2.Failure) { return try p2.parse(&input) } catch let error2 {
                    throw Failure(error0, error1, error2)
                }
            }
        }
    }
}

extension Parser.Take {

    public struct Two<P0: Parser.`Protocol`, P1: Parser.`Protocol`>
    where P0.Input == P1.Input {

        public let p0: P0

        public let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Parser.Take.Two: Parser.`Protocol` {

    public typealias Input = P0.Input

    public typealias Output = (P0.Output, P1.Output)

    public typealias Failure = Either<P0.Failure, P1.Failure>

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let o0: P0.Output
        do throws(P0.Failure) {
            o0 = try p0.parse(&input)
        } catch {
            throw .left(error)
        }
        let o1: P1.Output
        do throws(P1.Failure) {
            o1 = try p1.parse(&input)
        } catch {
            throw .right(error)
        }
        return (o0, o1)
    }
}

extension Parser.Take.Two {

    @inlinable
    public func map<NewOutput>(
        _ transform: @escaping (P0.Output, P1.Output) -> NewOutput
    ) -> Parser.Take.Two<P0, P1>.Map<NewOutput> {
        Map(upstream: self, transform: transform)
    }
}

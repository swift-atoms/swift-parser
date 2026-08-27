public import Either

extension Parser.Skip {

    public struct First<P0: Parser.`Protocol`, P1: Parser.`Protocol`>
    where P0.Input == P1.Input, P0.Output == Void {

        public let p0: P0

        public let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Parser.Skip.First: Parser.`Protocol` {

    public typealias Input = P0.Input

    public typealias Output = P1.Output

    public typealias Failure = Either<P0.Failure, P1.Failure>

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        do throws(P0.Failure) {
            _ = try p0.parse(&input)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            return try p1.parse(&input)
        } catch {
            throw .right(error)
        }
    }
}

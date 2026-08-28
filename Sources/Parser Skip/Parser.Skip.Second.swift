extension Parser.Skip {

    public struct Second<P0: Parser.`Protocol`, P1: Parser.`Protocol`>
    where P0.Input == P1.Input, P1.Output == Void {

        public let p0: P0

        public let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Parser.Skip.Second: Parser.`Protocol`
where P0.Output: Escapable {

    public typealias Input = P0.Input

    public typealias Output = P0.Output

    public typealias Failure = Either<P0.Failure, P1.Failure>

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let o0: P0.Output
        do throws(P0.Failure) {
            o0 = try p0.parse(&input)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            _ = try p1.parse(&input)
        } catch {
            throw .right(error)
        }
        return o0
    }
}

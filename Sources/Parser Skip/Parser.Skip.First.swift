extension Parser.Skip {

    public struct First<P0: Parser.`Protocol`, P1: Parser.`Protocol`>
    where
        P0.Input == P1.Input,
        P0.Input: ~Copyable & ~Escapable,
        P1.Input: ~Copyable & ~Escapable,
        P0.Output == Void,
        P1.Output: ~Copyable & ~Escapable
    {

        public let p0: P0

        public let p1: P1

        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Parser.Skip.First: Parser.`Protocol`
where
    P0.Input: ~Copyable & ~Escapable,
    P1.Input: ~Copyable & ~Escapable,
    P1.Output: ~Copyable & ~Escapable
{

    public typealias Input = P0.Input

    public typealias Output = P1.Output

    public typealias Failure = Either<P0.Failure, P1.Failure>

    @inlinable
    @_lifetime(borrow self, &input)
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

public import Pair
public import Parser

extension Parser {

    public struct Product<P0: Parser.`Protocol`, P1: Parser.`Protocol`, Failure: Swift.Error>: Parser.`Protocol`
    where
        P0.Input == P1.Input,
        P0.Input: ~Copyable & ~Escapable,
        P1.Input: ~Copyable & ~Escapable,
        P0.Output: ~Copyable & Escapable,
        P1.Output: ~Copyable & Escapable
    {
        public typealias Input = P0.Input

        public typealias Output = Pair::Pair<P0.Output, P1.Output>

        public let p0: P0

        public let p1: P1

        public let failure0: (P0.Failure) -> Failure

        public let failure1: (P1.Failure) -> Failure

        @inlinable
        public init(
            _ p0: P0,
            _ p1: P1,
            _ failure0: @escaping (P0.Failure) -> Failure,
            _ failure1: @escaping (P1.Failure) -> Failure
        ) {
            self.p0 = p0
            self.p1 = p1
            self.failure0 = failure0
            self.failure1 = failure1
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let first: P0.Output
            do throws(P0.Failure) {
                first = try p0.parse(&input)
            } catch {
                throw failure0(error)
            }
            let second: P1.Output
            do throws(P1.Failure) {
                second = try p1.parse(&input)
            } catch {
                throw failure1(error)
            }
            return Pair::Pair(first, second)
        }
    }
}

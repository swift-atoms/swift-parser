extension Parser {

    public struct Append<A: Parser.`Protocol` & ~Copyable, N: Parser.`Protocol` & ~Copyable, Failure: Swift.Error, each O>: Parser.`Protocol`, ~Copyable
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O)
    {
        public typealias Input = A.Input

        public typealias Output = (repeat each O, N.Output)

        public let accumulated: A

        public let next: N

        public let accumulatedFailure: (A.Failure) -> Failure

        public let nextFailure: (N.Failure) -> Failure

        @inlinable
        public init(
            _ accumulated: consuming A,
            _ next: consuming N,
            _ accumulatedFailure: @escaping (A.Failure) -> Failure,
            _ nextFailure: @escaping (N.Failure) -> Failure
        ) {
            self.accumulated = accumulated
            self.next = next
            self.accumulatedFailure = accumulatedFailure
            self.nextFailure = nextFailure
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let head: (repeat each O)
            do throws(A.Failure) {
                head = try accumulated.parse(&input)
            } catch {
                throw accumulatedFailure(error)
            }
            let last: N.Output
            do throws(N.Failure) {
                last = try next.parse(&input)
            } catch {
                throw nextFailure(error)
            }
            return (repeat each head, last)
        }
    }
}

extension Parser.Append: Copyable
where
    A: Parser.`Protocol`<A.Input, A.Output, A.Failure> & Copyable,
    N: Parser.`Protocol`<N.Input, N.Output, N.Failure> & Copyable,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable
{}

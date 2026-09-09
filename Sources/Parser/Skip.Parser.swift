public import Either

extension Skip
where Kept: ~Copyable & Escapable, Dropped: ~Copyable & Escapable {

    public struct Parser<A: Parsing & ~Copyable, N: Parsing & ~Copyable, Failure: Swift.Error>: Parsing, ~Copyable
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Output == Kept,
        N.Output == Dropped
    {
        public typealias Input = A.Input

        public typealias Output = A.Output

        public let base: Skip

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
            self.base = Skip()
            self.accumulated = accumulated
            self.next = next
            self.accumulatedFailure = accumulatedFailure
            self.nextFailure = nextFailure
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let output: A.Output
            do throws(A.Failure) {
                output = try accumulated.parse(&input)
            } catch {
                throw accumulatedFailure(error)
            }
            let dropped: Dropped
            do throws(N.Failure) {
                dropped = try next.parse(&input)
            } catch {
                throw nextFailure(error)
            }
            return base(output, dropped)
        }
    }
}

extension Skip.Parser: Copyable
where
    Kept: ~Copyable & Escapable,
    Dropped: ~Copyable & Escapable,
    A: Parsing<A.Input, A.Output, A.Failure> & Copyable,
    N: Parsing<N.Input, N.Output, N.Failure> & Copyable,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable,
    A.Output: ~Copyable & Escapable,
    N.Output: ~Copyable & Escapable
{}

extension Skip
where Kept: ~Copyable & Escapable, Dropped: ~Copyable & Escapable {

    @inlinable
    public func parser<A: Parsing & ~Copyable, N: Parsing & ~Copyable>(
        _ accumulated: consuming A, _ next: consuming N
    ) -> Parser<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Output == Kept, N.Output == Dropped
    {
        .init(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public func parser<A: Parsing & ~Copyable, N: Parsing & ~Copyable>(
        _ accumulated: consuming A, _ next: consuming N
    ) -> Parser<A, N, A.Failure>
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Output == Kept, N.Output == Dropped,
        A.Failure == N.Failure
    {
        .init(accumulated, next, { $0 }, { $0 })
    }
}

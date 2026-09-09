public import Either

extension Append
where
    Accumulated: ~Copyable & Escapable,
    Next: ~Copyable & Escapable,
    Output: ~Copyable & ~Escapable
{

    public typealias AppendFailure = Failure

    /// Parses two operands in order, then applies this append operation.
    ///
    /// Operand results must be escapable: the second parser mutates the input
    /// after the first result has been produced. Input and final output may be
    /// nonescapable. Failures preserve consumption; this adapter does not rewind.
    public struct Parser<
        A: Parsing & ~Copyable,
        N: Parsing & ~Copyable,
        ParseFailure: Swift.Error
    >: Parsing, ~Copyable
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Output == Accumulated,
        N.Output == Next
    {
        public typealias Input = A.Input

        public let base: Append
        public let accumulated: A
        public let next: N
        public let accumulatedFailure: (A.Failure) -> ParseFailure
        public let nextFailure: (N.Failure) -> ParseFailure
        public let appendFailure: (Failure) -> ParseFailure

        @inlinable
        public init(
            _ base: Append,
            _ accumulated: consuming A,
            _ next: consuming N,
            accumulatedFailure: @escaping (A.Failure) -> ParseFailure,
            nextFailure: @escaping (N.Failure) -> ParseFailure,
            appendFailure: @escaping (Failure) -> ParseFailure
        ) {
            self.base = base
            self.accumulated = accumulated
            self.next = next
            self.accumulatedFailure = accumulatedFailure
            self.nextFailure = nextFailure
            self.appendFailure = appendFailure
        }

        @inlinable
        @_lifetime(borrow self)
        public borrowing func parse(_ input: inout Input) throws(ParseFailure) -> Output {
            let head: Accumulated
            do throws(A.Failure) {
                head = try accumulated.parse(&input)
            } catch {
                throw accumulatedFailure(error)
            }
            let last: Next
            do throws(N.Failure) {
                last = try next.parse(&input)
            } catch {
                throw nextFailure(error)
            }
            do throws(AppendFailure) {
                return try base(head, last)
            } catch {
                throw appendFailure(error)
            }
        }
    }

    /// Distinguishes accumulated, next, and append failures as
    /// `.left(.left(error))`, `.left(.right(error))`, and `.right(error)`.
    @inlinable
    public func parser<A: Parsing & ~Copyable, N: Parsing & ~Copyable>(
        _ accumulated: consuming A,
        _ next: consuming N
    ) -> Parser<A, N, Either<Either<A.Failure, N.Failure>, Failure>>
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Output == Accumulated,
        N.Output == Next
    {
        .init(self, accumulated, next,
              accumulatedFailure: { .left(.left($0)) },
              nextFailure: { .left(.right($0)) },
              appendFailure: { .right($0) })
    }

    /// Preserves a shared failure type, including `Never` for nonthrowing stages.
    @inlinable
    public func parser<A: Parsing & ~Copyable, N: Parsing & ~Copyable>(
        _ accumulated: consuming A,
        _ next: consuming N
    ) -> Parser<A, N, Failure>
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Output == Accumulated,
        N.Output == Next,
        A.Failure == Failure,
        N.Failure == Failure
    {
        .init(self, accumulated, next,
              accumulatedFailure: { $0 },
              nextFailure: { $0 },
              appendFailure: { $0 })
    }
}

extension Append.Parser: Copyable
where
    Accumulated: ~Copyable & Escapable,
    Next: ~Copyable & Escapable,
    Output: ~Copyable & ~Escapable,
    A: Parsing<A.Input, A.Output, A.Failure> & Copyable,
    N: Parsing<N.Input, N.Output, N.Failure> & Copyable,
    A.Input: ~Copyable & ~Escapable,
    N.Input: ~Copyable & ~Escapable,
    A.Output: ~Copyable & Escapable,
    N.Output: ~Copyable & Escapable
{}

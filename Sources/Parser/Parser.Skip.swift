extension Parser {

    public struct Skip<A: Parser.`Protocol`, N: Parser.`Protocol`, Failure: Swift.Error>: Parser.`Protocol`
    where
        A.Input == N.Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output == Void
    {
        public typealias Input = A.Input

        public typealias Output = A.Output

        public let accumulated: A

        public let next: N

        public let accumulatedFailure: (A.Failure) -> Failure

        public let nextFailure: (N.Failure) -> Failure

        @inlinable
        public init(
            _ accumulated: A,
            _ next: N,
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
            let output: A.Output
            do throws(A.Failure) {
                output = try accumulated.parse(&input)
            } catch {
                throw accumulatedFailure(error)
            }
            do throws(N.Failure) {
                try next.parse(&input)
            } catch {
                throw nextFailure(error)
            }
            return output
        }
    }
}

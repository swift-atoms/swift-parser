public import Parser

extension Parser.Skip {

    public struct First<S: Parser.`Protocol`, V: Parser.`Protocol`, Failure: Swift.Error>: Parser.`Protocol`
    where
        S.Input == V.Input,
        S.Input: ~Copyable & ~Escapable,
        V.Input: ~Copyable & ~Escapable,
        S.Output == Void,
        V.Output: ~Copyable & ~Escapable
    {
        public typealias Input = S.Input

        public typealias Output = V.Output

        public let skipped: S

        public let value: V

        public let skippedFailure: (S.Failure) -> Failure

        public let valueFailure: (V.Failure) -> Failure

        @inlinable
        public init(
            _ skipped: S,
            _ value: V,
            _ skippedFailure: @escaping (S.Failure) -> Failure,
            _ valueFailure: @escaping (V.Failure) -> Failure
        ) {
            self.skipped = skipped
            self.value = value
            self.skippedFailure = skippedFailure
            self.valueFailure = valueFailure
        }

        @inlinable
        @_lifetime(borrow self, &input)
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            do throws(S.Failure) {
                try skipped.parse(&input)
            } catch {
                throw skippedFailure(error)
            }
            do throws(V.Failure) {
                return try value.parse(&input)
            } catch {
                throw valueFailure(error)
            }
        }
    }
}

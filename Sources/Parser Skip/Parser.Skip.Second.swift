public import Parser

extension Parser.Skip {

    public struct Second<V: Parser.`Protocol`, S: Parser.`Protocol`, Failure: Swift.Error>: Parser.`Protocol`
    where
        S.Input == V.Input,
        S.Input: ~Copyable & ~Escapable,
        V.Input: ~Copyable & ~Escapable,
        S.Output == Void,
        V.Output: ~Copyable & Escapable
    {
        public typealias Input = V.Input

        public typealias Output = V.Output

        public let value: V

        public let skipped: S

        public let valueFailure: (V.Failure) -> Failure

        public let skippedFailure: (S.Failure) -> Failure

        @inlinable
        public init(
            _ value: V,
            _ skipped: S,
            _ valueFailure: @escaping (V.Failure) -> Failure,
            _ skippedFailure: @escaping (S.Failure) -> Failure
        ) {
            self.value = value
            self.skipped = skipped
            self.valueFailure = valueFailure
            self.skippedFailure = skippedFailure
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let output: V.Output
            do throws(V.Failure) {
                output = try value.parse(&input)
            } catch {
                throw valueFailure(error)
            }
            do throws(S.Failure) {
                try skipped.parse(&input)
            } catch {
                throw skippedFailure(error)
            }
            return output
        }
    }
}

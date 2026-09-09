#if Pair
public import Either
public import Pair

extension Pair::Pair
where
    First: Parser::Parsing & ~Copyable,
    Second: Parser::Parsing & ~Copyable,
    First.Input == Second.Input,
    First.Input: ~Copyable & ~Escapable,
    Second.Input: ~Copyable & ~Escapable,
    First.Output: ~Copyable & Escapable,
    Second.Output: ~Copyable & Escapable
{

    public struct Parser<Failure: Swift.Error>: Parser::Parsing, ~Copyable {

        public typealias Input = First.Input

        public typealias Output = Pair::Pair<First.Output, Second.Output>

        public let first: First

        public let second: Second

        public let firstFailure: (First.Failure) -> Failure

        public let secondFailure: (Second.Failure) -> Failure

        @inlinable
        public init(
            _ first: consuming First,
            _ second: consuming Second,
            _ firstFailure: @escaping (First.Failure) -> Failure,
            _ secondFailure: @escaping (Second.Failure) -> Failure
        ) {
            self.first = first
            self.second = second
            self.firstFailure = firstFailure
            self.secondFailure = secondFailure
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let firstOutput: First.Output
            do throws(First.Failure) {
                firstOutput = try first.parse(&input)
            } catch {
                throw firstFailure(error)
            }
            let secondOutput: Second.Output
            do throws(Second.Failure) {
                secondOutput = try second.parse(&input)
            } catch {
                throw secondFailure(error)
            }
            return Output(firstOutput, secondOutput)
        }
    }

    @inlinable
    public consuming func parser() -> Pair::Pair<First, Second>.Parser<Either<First.Failure, Second.Failure>> {
        .init(first, second, { .left($0) }, { .right($0) })
    }

    @inlinable
    public consuming func parser() -> Pair::Pair<First, Second>.Parser<First.Failure>
    where First.Failure == Second.Failure {
        .init(first, second, { $0 }, { $0 })
    }
}

extension Pair::Pair.Parser: Copyable
where
    First: Parser::Parsing<First.Input, First.Output, First.Failure> & Copyable,
    Second: Parser::Parsing<Second.Input, Second.Output, Second.Failure> & Copyable,
    First.Input: ~Copyable & ~Escapable,
    Second.Input: ~Copyable & ~Escapable,
    First.Output: ~Copyable & Escapable,
    Second.Output: ~Copyable & Escapable
{}

#endif

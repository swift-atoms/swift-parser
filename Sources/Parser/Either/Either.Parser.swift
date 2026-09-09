#if Either
public import Either

extension Either
where
    Left: Parser::Parsing & ~Copyable,
    Right: Parser::Parsing & ~Copyable,
    Left.Input == Right.Input,
    Left.Output == Right.Output,
    Left.Input: ~Copyable & ~Escapable,
    Right.Input: ~Copyable & ~Escapable,
    Left.Output: ~Copyable & ~Escapable,
    Right.Output: ~Copyable & ~Escapable
{
    public struct Parser: Parser::Parsing, ~Copyable {
        public typealias Input = Left.Input
        public typealias Output = Left.Output
        public typealias Failure = Either<Left.Failure, Right.Failure>

        public let wrapped: Either<Left, Right>

        @inlinable
        public init(_ wrapped: consuming Either<Left, Right>) {
            self.wrapped = wrapped
        }

        @inlinable
        @_lifetime(borrow self, &input)
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            switch wrapped {
            case .left(let parser):
                do throws(Left.Failure) {
                    return try parser.parse(&input)
                } catch {
                    throw .left(error)
                }
            case .right(let parser):
                do throws(Right.Failure) {
                    return try parser.parse(&input)
                } catch {
                    throw .right(error)
                }
            }
        }
    }

    @inlinable
    public consuming func parser() -> Parser {
        .init(self)
    }
}
extension Either.Parser: Copyable
where Left: Parser::Parsing<Left.Input, Left.Output, Left.Failure> & Copyable,
      Right: Parser::Parsing<Right.Input, Right.Output, Right.Failure> & Copyable,
      Left.Input: ~Copyable & ~Escapable, Right.Input: ~Copyable & ~Escapable,
      Left.Output: ~Copyable & ~Escapable, Right.Output: ~Copyable & ~Escapable {}
#endif

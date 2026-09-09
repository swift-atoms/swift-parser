#if Either
public import Either

extension Either: Parser::Parsing
where
    Left: Parser::Parsing & Copyable,
    Right: Parser::Parsing & Copyable,
    Left.Input == Right.Input,
    Left.Output == Right.Output,
    Left.Input: ~Copyable & ~Escapable,
    Right.Input: ~Copyable & ~Escapable,
    Left.Output: ~Copyable & Escapable,
    Right.Output: ~Copyable & Escapable
{

    public typealias Input = Left.Input

    public typealias Output = Left.Output

    public typealias Failure = Either<Left.Failure, Right.Failure>

    @inlinable
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        switch copy self {
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

#endif

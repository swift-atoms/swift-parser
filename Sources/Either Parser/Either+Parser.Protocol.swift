public import Either
public import Parser

extension Either: Parser::Parser.`Protocol`
where
    Left: Parser::Parser.`Protocol` & Copyable,
    Right: Parser::Parser.`Protocol` & Copyable,
    Left.Input == Right.Input,
    Left.Output == Right.Output,
    Left.Output: Escapable
{

    public typealias Input = Left.Input

    public typealias Output = Left.Output

    public typealias Failure = Either<Left.Failure, Right.Failure>

    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        switch self {
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

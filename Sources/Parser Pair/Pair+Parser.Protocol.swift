extension Pair: Parser.`Protocol`
where
    First: Parser.`Protocol`,
    Second: Parser.`Protocol`,
    First.Input == Second.Input
{

    public typealias Input = First.Input

    public typealias Output = (First.Output, Second.Output)

    public typealias Failure = Either<First.Failure, Second.Failure>

    @inlinable
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        let o0: First.Output
        do throws(First.Failure) {
            o0 = try first.parse(&input)
        } catch {
            throw .left(error)
        }
        let o1: Second.Output
        do throws(Second.Failure) {
            o1 = try second.parse(&input)
        } catch {
            throw .right(error)
        }
        return (o0, o1)
    }
}

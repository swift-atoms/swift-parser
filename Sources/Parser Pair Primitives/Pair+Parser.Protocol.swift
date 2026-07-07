//
//  Pair+Parser.Protocol.swift
//  swift-parser-primitives
//
//  Pair<First, Second> as a sequential parser combinator,
//  reusing the binary product primitive from swift-pair-primitives.
//

extension Pair: Parser.`Protocol`
where
    First: Parser.`Protocol`,
    Second: Parser.`Protocol`,
    First.Input == Second.Input
{
    /// The input type this parser consumes.
    public typealias Input = First.Input
    /// The output type this parser produces: a tuple of both parsers' outputs.
    public typealias Output = (First.Output, Second.Output)
    /// The error type this parser can throw, discriminating which parser failed.
    public typealias Failure = Either<First.Failure, Second.Failure>

    /// Parses the first parser, then the second, returning both outputs as a tuple.
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

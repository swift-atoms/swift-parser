public import Parser_Primitive
public import Tagged_Primitives

extension Tagged where Underlying: Parseable, Underlying.Parser.Output == Underlying {

    public struct UnderlyingParser {

        @inlinable
        public init() {}
    }
}

extension Tagged.UnderlyingParser: Parser_Primitive.Parser.`Protocol`
where
    Underlying: Parseable,
    Underlying.Parser.Output == Underlying
{

    public typealias Input = Underlying.Parser.Input

    public typealias Output = Tagged<Tag, Underlying>

    public typealias Failure = Underlying.Parser.Failure

    public typealias Body = Never

    @inlinable
    public borrowing func parse(
        _ input: inout Underlying.Parser.Input
    ) throws(Underlying.Parser.Failure) -> Tagged<Tag, Underlying> {
        let underlying = try Underlying.parser.parse(&input)
        return Tagged<Tag, Underlying>(_unchecked: underlying)
    }
}

extension Tagged: Parseable
where
    Underlying: Parseable,
    Underlying.Parser.Output == Underlying
{

    @inlinable
    public static var parser: Tagged<Tag, Underlying>.UnderlyingParser {
        Tagged<Tag, Underlying>.UnderlyingParser()
    }
}

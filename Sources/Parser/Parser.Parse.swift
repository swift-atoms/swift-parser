extension Parser {

    @frozen
    public struct Parse<P: Parser.`Protocol` & ~Copyable>: ~Copyable
    where
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable
    {

        public let parser: P

        @inlinable
        public init(parser: consuming P) {
            self.parser = parser
        }
    }
}

extension Parser.Parse: Copyable
where
    P: Parser.`Protocol`<P.Input, P.Output, P.Failure> & Copyable
{}

extension Parser.`Protocol`
where
    Self: Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    @inlinable
    public var parse: Parser.Parse<Self> {
        consuming get { Parser.Parse(parser: self) }
    }
}

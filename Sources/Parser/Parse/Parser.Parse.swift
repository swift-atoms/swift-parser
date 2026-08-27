extension Parser {

    @frozen
    public struct Parse<P: Parser.`Protocol` & ~Copyable>: ~Copyable {

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

extension Parser.`Protocol` {

    @inlinable
    public var parse: Parser.Parse<Self> {
        Parser.Parse(parser: self)
    }
}

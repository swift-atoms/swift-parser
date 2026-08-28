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
    P: Parser.`Protocol` & Copyable
{}

extension Parser.`Protocol` where Self: Copyable {

    @inlinable
    public var parse: Parser.Parse<Self> {
        consuming get { Parser.Parse(parser: self) }
    }
}

#if Tagged
public import Tagged

extension Tagged::Tagged {
    public struct Parser<UnderlyingParser: ~Copyable>: ~Copyable {
        public let underlying: UnderlyingParser

        @inlinable
        public init(_ underlying: consuming UnderlyingParser) {
            self.underlying = underlying
        }
    }
}

extension Tagged::Tagged.Parser: Copyable where UnderlyingParser: Copyable {}

extension Tagged::Tagged.Parser: Parser::Parsing
where
    UnderlyingParser: Parser::Parsing & ~Copyable,
    UnderlyingParser.Input: ~Copyable & ~Escapable,
    UnderlyingParser.Output == Underlying
{
    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf parser: implement parse(_:) directly")
        }
    }

    @inlinable
    public borrowing func parse(
        _ input: inout UnderlyingParser.Input
    ) throws(UnderlyingParser.Failure) -> Tagged::Tagged<Tag, Underlying> {
        let value = try underlying.parse(&input)
        return Tagged::Tagged<Tag, Underlying>(_unchecked: value)
    }
}
#endif

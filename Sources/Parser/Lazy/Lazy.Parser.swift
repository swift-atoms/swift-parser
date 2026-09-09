#if Lazy
public import Lazy

extension Lazy::Lazy
where
    Value: Parser::Parsing,
    Value.Input: ~Copyable & ~Escapable,
    Value.Output: ~Copyable & Escapable
{
    public struct Parser: Parser::Parsing {
        public typealias Input = Value.Input
        public typealias Output = Value.Output
        public typealias Failure = Value.Failure

        public let wrapped: Lazy::Lazy<Value>

        @inlinable
        public init(_ wrapped: Lazy::Lazy<Value>) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try wrapped.value.parse(&input)
        }
    }

    @inlinable
    public func parser() -> Parser {
        .init(self)
    }
}
#endif

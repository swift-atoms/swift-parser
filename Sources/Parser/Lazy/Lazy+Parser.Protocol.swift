#if Lazy
public import Lazy

extension Lazy::Lazy: Parser::Parsing
where
    Value: Parser::Parsing,
    Value.Input: ~Copyable & ~Escapable,
    Value.Output: ~Copyable & Escapable
{

    public typealias Input = Value.Input

    public typealias Output = Value.Output

    public typealias Failure = Value.Failure

    @inlinable
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        try value.parse(&input)
    }
}

#endif

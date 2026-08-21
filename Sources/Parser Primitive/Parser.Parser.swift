extension Parser {

    public protocol `Protocol`<Input, Output, Failure>: ~Copyable {

        associatedtype Input: ~Copyable & ~Escapable

        associatedtype Output

        associatedtype Failure: Swift.Error = Never

        associatedtype Body: ~Copyable

        @Parser.Builder<Input>
        var body: Body { borrowing get }

        borrowing func parse(_ input: inout Input) throws(Failure) -> Output
    }
}

extension Parser.`Protocol`
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Body == Never
{

    @inlinable
    public var body: Never {
        borrowing get {
            fatalError("\(Self.self) is a leaf parser — implement parse(_:) directly")
        }
    }
}

extension Parser.`Protocol`
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,

    Body: Parser.`Protocol`<Input, Output, Failure>
{

    @inlinable
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        try body.parse(&input)
    }
}

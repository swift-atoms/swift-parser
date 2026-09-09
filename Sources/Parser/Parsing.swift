public protocol Parsing<Input, Output, Failure>: ~Copyable {

    associatedtype Input: ~Copyable & ~Escapable

    associatedtype Output: ~Copyable & ~Escapable

    associatedtype Failure: Swift.Error = Never

    associatedtype Body: ~Copyable = Never

    @Builder<Input>
    var body: Body { borrowing get }

    @_lifetime(borrow self, &input)
    borrowing func parse(_ input: inout Input) throws(Failure) -> Output
}

extension Parsing
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable,
    Body == Never
{

    @inlinable
    public var body: Never {
        borrowing get {
            fatalError("\(Self.self) is a leaf parser: implement parse(_:) directly")
        }
    }
}

extension Parsing
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & Escapable,
    Body: Parsing & ~Copyable,
    Body.Input: ~Copyable & ~Escapable,
    Body.Output: ~Copyable & Escapable
{

    @inlinable
    public borrowing func parse(_ input: inout Body.Input) throws(Body.Failure) -> Body.Output {
        try body.parse(&input)
    }
}

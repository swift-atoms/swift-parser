extension Parser {

    public struct Sequence<Input: ~Copyable & ~Escapable, Body: Parser.`Protocol` & ~Copyable>: Parser.`Protocol`, ~Copyable
    where
        Body.Input == Input,
        Body.Output: ~Copyable & ~Escapable
    {
        public typealias Output = Body.Output

        public typealias Failure = Body.Failure

        public let body: Body

        @inlinable
        public init(
            _: Input.Type = Input.self,
            @Parser.Builder<Input> _ build: () -> Body
        ) {
            self.body = build()
        }

        @inlinable
        @_lifetime(borrow self, &input)
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try body.parse(&input)
        }
    }
}

extension Parser.Sequence: Copyable
where
    Input: ~Copyable & ~Escapable,
    Body: Parser.`Protocol`<Input, Body.Output, Body.Failure> & Copyable,
    Body.Output: ~Copyable & ~Escapable
{}

extension Sequence
where
    Body: Parsing & ~Copyable,
    Body.Input: ~Copyable & ~Escapable,
    Body.Output: ~Copyable & ~Escapable
{

    public struct Parser<Input: ~Copyable & ~Escapable>: Parsing, ~Copyable
    where Body.Input == Input {

        public typealias Output = Body.Output
        public typealias Failure = Body.Failure

        public let base: Sequence

        @inlinable
        public init(_ base: consuming Sequence) {
            self.base = base
        }

        @inlinable
        public init(
            _: Input.Type = Input.self,
            @Parser::Parser.Builder<Input> _ build: () -> Body
        ) {
            self.base = Sequence(build())
        }

        @inlinable
        @_lifetime(borrow self, &input)
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try base.body.parse(&input)
        }
    }

    @inlinable
    public consuming func parser() -> Parser<Body.Input> {
        .init(self)
    }
}

extension Sequence.Parser: Copyable
where
    Input: ~Copyable & ~Escapable,
    Body: Parsing<Body.Input, Body.Output, Body.Failure> & Copyable,
    Body.Input: ~Copyable & ~Escapable,
    Body.Output: ~Copyable & ~Escapable
{}

extension Parser.OneOf {

    public struct Sequence<Input, Output, Body: Parser.`Protocol`>
    where Body.Input == Input, Body.Output == Output {

        public let body: Body

        @inlinable
        public init(
            @Parser.OneOf.Builder<Input, Output> _ build: () -> Body
        ) {
            self.body = build()
        }
    }
}

extension Parser.OneOf.Sequence: Parser.`Protocol` {

    public typealias Failure = Body.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try body.parse(&input)
    }
}

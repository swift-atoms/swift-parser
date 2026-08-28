extension Parser.Take {

    public struct Transform<Input, BodyOutput, Output, Body: Parser.`Protocol`>
    where Body.Input == Input, Body.Output == BodyOutput {

        public let body: Body

        @usableFromInline
        let transform: (BodyOutput) -> Output

        @inlinable
        public init(
            _ transform: @escaping (BodyOutput) -> Output,
            @Parser.Builder<Input> _ build: () -> Body
        ) {
            self.body = build()
            self.transform = transform
        }
    }
}

extension Parser.Take.Transform: Parser.`Protocol` {

    public typealias Failure = Body.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        transform(try body.parse(&input))
    }
}

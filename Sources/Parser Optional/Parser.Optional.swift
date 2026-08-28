extension Parser {

    public struct Optional<Wrapped: Parser.`Protocol`> {

        public let wrapped: Wrapped?

        @inlinable
        public init(_ wrapped: Wrapped?) {
            self.wrapped = wrapped
        }
    }
}

extension Parser.Optional: Parser.`Protocol` {

    public typealias Input = Wrapped.Input

    public typealias Output = Wrapped.Output?

    public typealias Failure = Wrapped.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard let wrapped else {
            return nil
        }
        return try wrapped.parse(&input)
    }
}

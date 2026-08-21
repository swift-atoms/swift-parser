extension Parser.Conversion {

    public struct Witness<Input, Output, Failure: Swift.Error> {

        public var _apply: (Input) throws(Failure) -> Output

        public var _unapply: (Output) throws(Failure) -> Input

        @inlinable
        public init(
            apply: @escaping (Input) throws(Failure) -> Output,
            unapply: @escaping (Output) throws(Failure) -> Input
        ) {
            self._apply = apply
            self._unapply = unapply
        }
    }
}

extension Parser.Conversion.Witness: Parser.Conversion.`Protocol` {

    @inlinable
    public func apply(_ input: Input) throws(Failure) -> Output {
        try _apply(input)
    }

    @inlinable
    public func unapply(_ output: Output) throws(Failure) -> Input {
        try _unapply(output)
    }
}

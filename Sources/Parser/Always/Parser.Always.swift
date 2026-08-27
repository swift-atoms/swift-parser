extension Parser {

    public struct Always<Input, Output> {

        public let output: Output

        @inlinable
        public init(_ output: Output) {
            self.output = output
        }
    }
}

extension Parser.Always: Parser.`Protocol` {

    public typealias Failure = Never

    @inlinable
    public func parse(_ input: inout Input) -> Output {
        output
    }
}

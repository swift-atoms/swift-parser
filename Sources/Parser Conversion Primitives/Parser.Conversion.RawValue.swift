extension Parser.Conversion {

    public struct RawValue<Output: RawRepresentable> {

        @inlinable
        public init() {}
    }
}

extension Parser.Conversion.RawValue: Parser.Conversion.`Protocol` {

    public typealias Input = Output.RawValue

    public typealias Failure = Parser.Conversion.Error

    @inlinable
    public func apply(_ input: Output.RawValue) throws(Parser.Conversion.Error) -> Output {
        guard let output = Output(rawValue: input) else {
            throw .unrepresentable
        }
        return output
    }

    @inlinable
    public func unapply(_ output: Output) -> Output.RawValue {
        output.rawValue
    }
}

extension Parser.Conversion.`Protocol` {

    @inlinable
    public static func representing<Output>(
        _ type: Output.Type
    ) -> Self where Self == Parser.Conversion.RawValue<Output> {
        .init()
    }
}

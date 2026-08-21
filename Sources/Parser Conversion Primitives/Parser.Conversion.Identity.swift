extension Parser.Conversion {

    public struct Identity<Value> {

        @inlinable
        public init() {}
    }
}

extension Parser.Conversion.Identity: Parser.Conversion.`Protocol` {

    public typealias Input = Value

    public typealias Output = Value

    public typealias Failure = Never

    @inlinable
    public func apply(_ input: Value) -> Value { input }

    @inlinable
    public func unapply(_ output: Value) -> Value { output }
}

extension Parser.Conversion.`Protocol` {

    @inlinable
    public static func identity<Value>() -> Self
    where Self == Parser.Conversion.Identity<Value> {
        .init()
    }
}

extension Parser.Conversion {

    public struct Fixed<Output: Equatable> {
        @usableFromInline
        internal let value: Output

        @inlinable
        public init(_ value: Output) {
            self.value = value
        }
    }
}

extension Parser.Conversion.Fixed: Parser.Conversion.`Protocol` {

    public typealias Input = Void

    public typealias Failure = Parser.Conversion.Error

    @inlinable
    public func apply(_ input: Void) -> Output { value }

    @inlinable
    public func unapply(_ output: Output) throws(Parser.Conversion.Error) {
        guard output == value else {
            throw .mismatch
        }
    }
}

extension Parser.Conversion.`Protocol` {

    @inlinable
    public static func fixed<Output>(
        _ value: Output
    ) -> Self where Self == Parser.Conversion.Fixed<Output> {
        .init(value)
    }
}

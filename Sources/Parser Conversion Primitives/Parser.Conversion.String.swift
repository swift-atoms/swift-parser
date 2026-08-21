extension Parser.Conversion {

    public struct String {

        @inlinable
        public init() {}
    }
}

extension Parser.Conversion.String: Parser.Conversion.`Protocol` {

    public typealias Input = Substring

    public typealias Output = Swift.String

    public typealias Failure = Never

    @inlinable
    public func apply(_ input: Substring) -> Swift.String {
        Swift.String(input)
    }

    @inlinable
    public func unapply(_ output: Swift.String) -> Substring {
        Substring(output)
    }
}

extension Parser.Conversion.`Protocol` where Self == Parser.Conversion.String {

    @inlinable
    public static var string: Self { .init() }
}

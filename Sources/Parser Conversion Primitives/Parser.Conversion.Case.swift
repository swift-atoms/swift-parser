extension Parser.Conversion {

    public struct Case<Root, Value> {
        @usableFromInline
        internal let embed: (Value) -> Root

        @usableFromInline
        internal let extract: (Root) -> Value?

        @inlinable
        public init(
            embed: @escaping (Value) -> Root,
            extract: @escaping (Root) -> Value?
        ) {
            self.embed = embed
            self.extract = extract
        }
    }
}

extension Parser.Conversion.Case: Parser.Conversion.`Protocol` {

    public typealias Input = Value

    public typealias Output = Root

    public typealias Failure = Parser.Conversion.Error

    @inlinable
    public func apply(_ input: Value) -> Root { embed(input) }

    @inlinable
    public func unapply(_ output: Root) throws(Parser.Conversion.Error) -> Value {
        guard let value = extract(output) else {
            throw .absentCase
        }
        return value
    }
}

extension Parser.Conversion.`Protocol` {

    @inlinable
    public static func `case`<Root, Value>(
        embed: @escaping (Value) -> Root,
        extract: @escaping (Root) -> Value?
    ) -> Self where Self == Parser.Conversion.Case<Root, Value> {
        .init(embed: embed, extract: extract)
    }
}

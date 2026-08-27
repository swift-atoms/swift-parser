extension Parser.Conversion {

    public struct Memberwise<Values, Struct> {
        @usableFromInline
        internal let embed: (Values) -> Struct

        @usableFromInline
        internal let project: (Struct) -> Values

        @inlinable
        public init(
            embed: @escaping (Values) -> Struct,
            project: @escaping (Struct) -> Values
        ) {
            self.embed = embed
            self.project = project
        }
    }
}

extension Parser.Conversion.Memberwise: Parser.Conversion.`Protocol` {

    public typealias Input = Values

    public typealias Output = Struct

    public typealias Failure = Never

    @inlinable
    public func apply(_ input: Values) -> Struct { embed(input) }

    @inlinable
    public func unapply(_ output: Struct) -> Values { project(output) }
}

extension Parser.Conversion.`Protocol` {

    @inlinable
    public static func memberwise<Values, Struct>(
        _ embed: @escaping (Values) -> Struct,
        _ project: @escaping (Struct) -> Values
    ) -> Self where Self == Parser.Conversion.Memberwise<Values, Struct> {
        .init(embed: embed, project: project)
    }
}

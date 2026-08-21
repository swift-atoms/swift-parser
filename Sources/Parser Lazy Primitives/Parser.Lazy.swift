extension Parser {

    public struct Lazy<P: Parser.`Protocol`> {
        @usableFromInline
        internal let build: () -> P

        @inlinable
        public init(_ build: @escaping @autoclosure () -> P) {
            self.build = build
        }

        @inlinable
        public init(_ build: @escaping () -> P) {
            self.build = build
        }
    }
}

extension Parser.Lazy: Parser.`Protocol` {

    public typealias Input = P.Input

    public typealias Output = P.Output

    public typealias Failure = P.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try build().parse(&input)
    }
}

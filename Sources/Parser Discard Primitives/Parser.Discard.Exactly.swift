public import Collection_Primitives

extension Parser.Discard {

    public struct Exactly<Input: Collection.Slice.`Protocol`> {
        @usableFromInline
        let count: Int

        @inlinable
        public init(_ count: Int) {
            self.count = count
        }
    }
}

extension Parser.Discard.Exactly: Parser.`Protocol` {

    public typealias Output = Void

    public typealias Failure = Parser.Constraint.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        _ = try Parser.Consume.Exactly<Input>(count).parse(&input)
    }
}

public import Collection_Primitives

extension Parser {

    public struct End<Input: Collection.Slice.`Protocol`> {

        @inlinable
        public init() {}
    }
}

extension Parser.End: Parser.`Protocol` {

    public typealias Output = Void

    public typealias Failure = Parser.Match.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        guard input.isEmpty else {
            throw .expectedEnd(remaining: input.remainingCount)
        }
    }
}

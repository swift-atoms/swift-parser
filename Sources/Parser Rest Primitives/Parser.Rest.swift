public import Collection_Primitives

extension Parser {

    public struct Rest<Input: Collection.Slice.`Protocol`> {

        @inlinable
        public init() {}
    }
}

extension Parser.Rest: Parser.`Protocol` {

    public typealias Output = Input

    public typealias Failure = Never

    @inlinable
    public func parse(_ input: inout Input) -> Output {
        let result = input
        input = input[input.endIndex...]
        return result
    }
}

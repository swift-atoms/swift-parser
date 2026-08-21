public import Collection_Primitives

extension Parser.Prefix {

    public struct While<Input: Collection.Slice.`Protocol`>
    where Input.Element: Copyable {
        @usableFromInline
        let minLength: Int

        @usableFromInline
        let maxLength: Int

        @usableFromInline
        let predicate: (Input.Element) -> Bool

        @inlinable
        public init(
            minLength: Int = 0,
            maxLength: Int? = nil,
            _ predicate: @escaping (Input.Element) -> Bool
        ) {
            self.minLength = minLength
            self.maxLength = maxLength ?? .max
            self.predicate = predicate
        }
    }
}

extension Parser.Prefix.While: Parser.`Protocol` {

    public typealias Output = Input

    public typealias Failure = Parser.Constraint.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        var count = 0
        var endIndex = input.startIndex

        while endIndex < input.endIndex {
            if count >= maxLength {
                break
            }
            guard predicate(input[endIndex]) else {
                break
            }
            input.formIndex(after: &endIndex)
            count += 1
        }

        guard count >= minLength else {
            throw .countTooLow(expected: minLength, got: count)
        }

        let result = input[input.startIndex..<endIndex]
        input = input[endIndex...]
        return result
    }
}

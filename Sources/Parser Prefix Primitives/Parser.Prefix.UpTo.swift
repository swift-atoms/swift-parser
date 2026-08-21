public import Collection_Primitives

extension Parser.Prefix {

    public struct UpTo<Input: Collection.Slice.`Protocol`>

    where Input.Element: Equatable, Input.Element: Copyable {
        @usableFromInline
        let delimiter: [Input.Element]

        @inlinable
        public init(_ delimiter: [Input.Element]) {
            self.delimiter = delimiter
        }
    }
}

extension Parser.Prefix.UpTo: Parser.`Protocol` {

    public typealias Output = Input

    public typealias Failure = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        var endIndex = input.startIndex

        outer: while endIndex < input.endIndex {

            var checkIndex = endIndex
            for element in delimiter {
                guard checkIndex < input.endIndex else {
                    break outer
                }
                guard input[checkIndex] == element else {

                    input.formIndex(after: &endIndex)
                    continue outer
                }
                input.formIndex(after: &checkIndex)
            }

            break
        }

        let result = input[input.startIndex..<endIndex]
        input = input[endIndex...]
        return result
    }
}

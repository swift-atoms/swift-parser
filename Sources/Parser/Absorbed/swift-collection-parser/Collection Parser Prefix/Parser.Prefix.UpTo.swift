#if CollectionLeaves
public import Collection

extension Parser::Prefix {

    public struct UpTo<Input: Collection.Slice.`Protocol`>: Parsing
    where Input.Element: Equatable, Input.Element: Copyable {
        @inlinable
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf parser: implement parse(_:) directly")
            }
        }


        public typealias Output = Input

        public typealias Failure = Never

        @usableFromInline
        let delimiter: [Input.Element]

        @inlinable
        public init(_ delimiter: [Input.Element]) {
            self.delimiter = delimiter
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) -> Output {
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
}
#endif

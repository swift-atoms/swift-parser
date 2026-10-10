#if CollectionLeaves
public import Parser_Core
public import Collection

    public struct Rest<Input: Collection.Slice.`Protocol`>: Parsing {


        public typealias Output = Input

        public typealias Failure = Never

        @inlinable
        public init() {}

        @inlinable
        public borrowing func parse(_ input: inout Input) -> Output {
            let result = input
            input = input[input.endIndex...]
            return result
        }
    }
#endif

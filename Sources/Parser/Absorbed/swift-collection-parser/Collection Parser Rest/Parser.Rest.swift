#if CollectionLeaves
public import Collection

    public struct Rest<Input: Collection.Slice.`Protocol`>: Parsing {
        @inlinable
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf parser: implement parse(_:) directly")
            }
        }


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

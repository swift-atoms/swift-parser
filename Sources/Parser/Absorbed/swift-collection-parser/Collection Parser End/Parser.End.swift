#if CollectionLeaves
public import Parser_Core
public import Collection

    public struct End<Input: Collection.Slice.`Protocol`>: Parsing {


        public typealias Output = Void

        public typealias Failure = Parser::End<Input>.Error

        @inlinable
        public init() {}

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) {
            guard input.isEmpty else {
                throw .expectedEnd(remaining: input.parserRemainingCount)
            }
        }
    }


extension Parser::End where Input: Collection.Slice.`Protocol` {

    public enum Error: Swift.Error, Equatable {
        case expectedEnd(remaining: Int)
    }
}
#endif

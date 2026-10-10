#if IteratorLeaves
public import Iterator

extension Parser::First {

    public struct Element<Source: Iterator.`Protocol` & ~Copyable & ~Escapable>: Parsing
    where Source.Element: Copyable & Escapable, Source.Failure == Never {
        @inlinable
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf parser: implement parse(_:) directly")
            }
        }


        public typealias Input = Source

        public typealias Output = Source.Element

        public typealias Failure = Parser::EndOfInput.Error

        @inlinable
        public init() {}

        @inlinable
        public borrowing func parse(_ input: inout Source) throws(Failure) -> Output {
            guard let element = input.next() else {
                throw .unexpected(expected: "any element")
            }

            return element
        }
    }
}
#endif

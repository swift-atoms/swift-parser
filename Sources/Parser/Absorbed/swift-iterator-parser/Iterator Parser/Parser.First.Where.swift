#if IteratorLeaves
public import Either
public import Iterator

extension Parser::First {

    public struct Where<Source: Iterator.`Protocol` & ~Copyable & ~Escapable>: Parsing
    where Source.Element: Copyable & Escapable, Source.Failure == Never {
        @inlinable
        public var body: Never {
            borrowing get {
                return fatalError("\(Self.self) is a leaf parser: implement parse(_:) directly")
            }
        }


        public typealias Input = Source

        public typealias Output = Source.Element

        public typealias Failure = Either<Parser::EndOfInput.Error, Parser::First.Where<Source>.Error>

        @usableFromInline
        let predicate: (Source.Element) -> Bool

        @usableFromInline
        let expected: String

        @inlinable
        public init(
            expected: String = "matching element",
            _ predicate: @escaping (Source.Element) -> Bool
        ) {
            self.predicate = predicate
            self.expected = expected
        }

        @inlinable
        public borrowing func parse(_ input: inout Source) throws(Failure) -> Output {
            guard let element = input.next() else {
                throw .left(.unexpected(expected: expected))
            }

            guard predicate(element) else {
                throw .right(.predicateFailed(expected: expected))
            }
            return element
        }
    }
}

extension Parser::First.Where
where Source: ~Copyable & ~Escapable, Source.Element: Copyable & Escapable, Source.Failure == Never {

    public enum Error: Swift.Error, Equatable {
        case predicateFailed(expected: String)
    }
}
#endif

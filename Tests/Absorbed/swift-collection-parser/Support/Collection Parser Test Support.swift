#if CollectionLeaves
public import Collection
public import Index
public import Iterator
public import Ordinal
public import Parser
public import Tagged
import Tagged



    public enum CollectionParserTest {}


extension CollectionParserTest {

    public struct Input: Sendable {

        @usableFromInline
        let bytes: [UInt8]

        @usableFromInline
        let _start: Int

        @usableFromInline
        let _end: Int

        @usableFromInline
        init(bytes: [UInt8], start: Int, end: Int) {
            self.bytes = bytes
            self._start = start
            self._end = end
        }

        @inlinable
        public init(_ bytes: [UInt8]) {
            self.init(bytes: bytes, start: 0, end: bytes.count)
        }

        @inlinable
        public init(utf8 string: Swift.String) {
            self.init([UInt8](string.utf8))
        }
    }
}

extension CollectionParserTest.Input: Collection.`Protocol` {

    public typealias Element = UInt8

    @inlinable
    public var startIndex: Index::Index<UInt8> {
        Index::Index<UInt8>(_unchecked: Ordinal::Ordinal(UInt(_start)))
    }

    @inlinable
    public var endIndex: Index::Index<UInt8> {
        Index::Index<UInt8>(_unchecked: Ordinal::Ordinal(UInt(_end)))
    }

    @inlinable
    public subscript(_ position: Index::Index<UInt8>) -> UInt8 {
        bytes[Int(bitPattern: position.underlying.rawValue)]
    }

    @inlinable
    public func index(after i: Index::Index<UInt8>) -> Index::Index<UInt8> {
        i.successor.saturating()
    }

    @inlinable
    @_lifetime(borrow self)
    public borrowing func makeIterator() -> Iterator::Iterator.Chunk<UInt8> {
        Iterator::Iterator.Chunk(bytes.span.extracting(_start..<_end))
    }
}

extension CollectionParserTest.Input: Collection.Slice.`Protocol` {

    @inlinable
    public subscript(bounds: Range<Index::Index<UInt8>>) -> Self {
        Self(
            bytes: bytes,
            start: Int(bitPattern: bounds.lowerBound.underlying.rawValue),
            end: Int(bitPattern: bounds.upperBound.underlying.rawValue)
        )
    }
}

extension CollectionParserTest.Input: ExpressibleByArrayLiteral {

    @inlinable
    public init(arrayLiteral elements: UInt8...) {
        self.init(elements)
    }
}

extension CollectionParserTest.Input: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.bytes[lhs._start..<lhs._end] == rhs.bytes[rhs._start..<rhs._end]
    }
}
#endif

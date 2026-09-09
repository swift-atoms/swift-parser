#if Repetition && Iterator && Collection
package import Collection
package import Index
package import Iterator
internal import Ordinal
internal import Tagged

package enum Fixture {}

extension Fixture {

  package struct Input: Sendable {

    let bytes: [UInt8]

    let _start: Int

    let _end: Int

    package init(bytes: [UInt8], start: Int, end: Int) {
      self.bytes = bytes
      self._start = start
      self._end = end
    }

    package init(_ bytes: [UInt8]) {
      self.init(bytes: bytes, start: 0, end: bytes.count)
    }

    package init(utf8 string: Swift.String) {
      self.init([UInt8](string.utf8))
    }
  }
}

extension Fixture.Input: Collection.`Protocol` {

  package typealias Element = UInt8

  package var startIndex: Index::Index<UInt8> {
    Index::Index<UInt8>(_unchecked: Ordinal::Ordinal(UInt(_start)))
  }

  package var endIndex: Index::Index<UInt8> {
    Index::Index<UInt8>(_unchecked: Ordinal::Ordinal(UInt(_end)))
  }

  package subscript(_ position: Index::Index<UInt8>) -> UInt8 {
    bytes[Int(bitPattern: position.underlying.rawValue)]
  }

  package func index(after i: Index::Index<UInt8>) -> Index::Index<UInt8> {
    i.successor.saturating()
  }

  @_lifetime(borrow self)
  package borrowing func makeIterator() -> Iterator::Iterator.Chunk<UInt8> {
    Iterator::Iterator.Chunk(bytes.span.extracting(_start..<_end))
  }
}

extension Fixture.Input: Collection.Slice.`Protocol` {

  package subscript(bounds: Range<Index::Index<UInt8>>) -> Self {
    Self(
      bytes: bytes,
      start: Int(bitPattern: bounds.lowerBound.underlying.rawValue),
      end: Int(bitPattern: bounds.upperBound.underlying.rawValue)
    )
  }
}

extension Fixture.Input: ExpressibleByArrayLiteral {

  package init(arrayLiteral elements: UInt8...) {
    self.init(elements)
  }
}

extension Fixture.Input: Equatable {

  package static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.bytes[lhs._start..<lhs._end] == rhs.bytes[rhs._start..<rhs._end]
  }
}

#endif

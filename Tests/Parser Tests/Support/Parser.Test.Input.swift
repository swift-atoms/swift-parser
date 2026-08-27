public import Collection
public import Input
public import Iterator
public import Parser

public typealias __ParserTestIterator = Iterator.Chunk<UInt8>

extension Parser.Test {

    public struct Input: Collection.Slice.`Protocol`, __ParserInput.`Protocol`, Sendable {
        public typealias Element = UInt8

        public let storage: [UInt8]

        @usableFromInline
        let lowerBound: Int

        @usableFromInline
        var position: Int

        @usableFromInline
        let upperBound: Int

        @inlinable
        public init(_ bytes: [UInt8]) {
            self.storage = bytes
            self.lowerBound = 0
            self.position = 0
            self.upperBound = bytes.count
        }

        @usableFromInline
        init(storage: [UInt8], bounds: Range<Int>) {
            self.storage = storage
            self.lowerBound = bounds.lowerBound
            self.position = bounds.lowerBound
            self.upperBound = bounds.upperBound
        }
    }
}

extension Parser.Test.Input {

    public typealias Index = Int

    public typealias Checkpoint = Int

    @inlinable
    public var startIndex: Index { position }

    @inlinable
    public var endIndex: Index { upperBound }

    @inlinable
    public var count: Int { upperBound - position }

    @inlinable
    public var isEmpty: Bool { position >= upperBound }

    @inlinable
    public var first: Element? {
        isEmpty ? nil : storage[position]
    }

    @inlinable
    public var checkpoint: Checkpoint { position }

    @inlinable
    public var bounds: ClosedRange<Checkpoint> { lowerBound...upperBound }

    @inlinable
    public subscript(position: Index) -> UInt8 {
        storage[position]
    }

    @inlinable
    public subscript(bounds: Range<Index>) -> Self {
        precondition(lowerBound <= bounds.lowerBound && bounds.upperBound <= upperBound)
        return Self(storage: storage, bounds: bounds)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        i + 1
    }

    @inlinable
    @_lifetime(borrow self)
    public borrowing func makeIterator() -> __ParserTestIterator {
        .init(
            storage.span
                .extracting(droppingFirst: position)
                .extracting(first: upperBound - position)
        )
    }

    @inlinable
    @discardableResult
    public mutating func advance() throws(__ParserInput.Stream.Error) -> UInt8 {
        guard !isEmpty else { throw .empty }
        let element = storage[position]
        position += 1
        return element
    }

    @inlinable
    public mutating func advance(by count: Int) {
        precondition(count >= 0 && count <= self.count)
        position += count
    }

    @inlinable
    public mutating func seek(to checkpoint: Checkpoint) {
        precondition(bounds.contains(checkpoint))
        position = checkpoint
    }
}

extension Parser.Test.Input: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: UInt8...) {
        self.init(elements)
    }
}

extension Parser.Test.Input: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else { return false }

        for offset in 0..<lhs.count {
            guard lhs.storage[lhs.position + offset] == rhs.storage[rhs.position + offset] else {
                return false
            }
        }

        return true
    }
}

extension Parser.Test.Input {

    public init(utf8 string: Swift.String) {
        self.init([UInt8](string.utf8))
    }
}

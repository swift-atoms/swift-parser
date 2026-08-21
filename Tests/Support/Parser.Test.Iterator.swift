public import Collection_Primitives
public import Iterator_Chunk_Primitives
public import Parser_Primitives

extension Parser.Test {

    public struct Iterator: __IteratorChunkProtocol, Sendable {
        @usableFromInline
        var _elements: [UInt8]

        @usableFromInline
        var _index: Int

        @inlinable
        public init(_ array: [UInt8]) {
            self._elements = array
            self._index = 0
        }
    }
}

extension Parser.Test.Iterator {
    public typealias Failure = Never

    @_lifetime(&self)
    @inlinable
    public mutating func next(maximumCount: some Carrier.`Protocol`<Cardinal>) -> Swift.Span<UInt8> {
        let remaining = _elements.count - _index
        let take = min(Int(maximumCount.underlying.rawValue), remaining)
        guard take > 0 else { return _elements.span.extracting(first: 0) }
        let start = _index
        _index += take
        return _elements.span
            .extracting(droppingFirst: start)
            .extracting(first: take)
    }
}

public import Collection_Primitives
public import Iterator_Chunk_Primitives
public import Parser_Primitives

extension Parser.Test {
    // WORKAROUND: omits the stdlib `IteratorProtocol` conformance.
    // WHY: the dual chunk-protocol + `IteratorProtocol` conformance trips a Swift
    //   6.3.3 (+Asserts) effects-check assertion (§A17; details in the doc below).
    // WHEN TO REMOVE: restore `, IteratorProtocol` once Windows CI has a fixed toolchain.
    // TRACKING: swift-institute/Issues/swift-issue-typed-throws-never-witness-effects-assertion

    /// Iterator over `[UInt8]` conforming to `Iterator.Chunk.Protocol`.
    ///
    /// Stores the array and an index for span-based iteration via
    /// `_elements.span.extracting()`.
    ///
    /// Does NOT conform to stdlib `IteratorProtocol`: Swift 6.3.3 (+Asserts) crashes
    /// type-checking a type that conforms to BOTH the chunk protocol and stdlib
    /// `IteratorProtocol` — `getEffects(req).contains(getEffects(witness))` assertion
    /// (TypeCheckProtocol.cpp:1311) where the chunk protocol's derived `next() throws(Never)`
    /// competes with the non-throwing `IteratorProtocol.next()`. Unused here anyway —
    /// `Parser.Test.Bytes` reaches `Iterable` via `Collection.Protocol`. Fixed on 6.5-dev;
    /// mirrors the `swift-input-primitives` fix (4262602).
    public struct Iterator: __IteratorChunkProtocol, Sendable {
        public typealias Failure = Never

        @usableFromInline
        var _elements: [UInt8]

        @usableFromInline
        var _index: Int

        @inlinable
        public init(_ array: [UInt8]) {
            self._elements = array
            self._index = 0
        }

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
}

#if IteratorLeaves
public import Iterator

/// Explicit iterator literal matching. A mismatch consumes the matching prefix and
/// the mismatching element, if present. Use `.backtracking()` for explicit rollback.
public struct ConsumingLiteral<Input: Iterator.`Protocol` & ~Copyable & ~Escapable>: Parsing
where Input.Element: Equatable & Copyable & Escapable, Input.Failure == Never {
    public typealias Output = Void
    public typealias Failure = Error
    public enum Error: Swift.Error, Equatable { case mismatch }
    public let elements: [Input.Element]

    @inlinable public init(_ elements: [Input.Element]) { self.elements = elements }

    @inlinable public borrowing func parse(_ input: inout Input) throws(Error) {
        for expected in elements {
            guard let actual = input.next(), actual == expected else { throw .mismatch }
        }
    }
}
#endif

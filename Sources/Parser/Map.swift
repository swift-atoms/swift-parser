/// A source bound to the Map family of operations.
@frozen
public struct Map<Source: ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
    public let source: Source

    @inlinable
    @_lifetime(copy source)
    public init(_ source: consuming Source) {
        self.source = source
    }
}

extension Map: Copyable where Source: Copyable & ~Escapable {}
extension Map: Escapable where Source: Escapable & ~Copyable {}

/// A source bound to the FlatMap family of operations.
@frozen
public struct FlatMap<Source: ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
    public let source: Source

    @inlinable
    @_lifetime(copy source)
    public init(_ source: consuming Source) {
        self.source = source
    }
}

extension FlatMap: Copyable where Source: Copyable & ~Escapable {}
extension FlatMap: Escapable where Source: Escapable & ~Copyable {}

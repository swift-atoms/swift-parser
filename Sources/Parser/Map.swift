/// A typed transformation of one value into another, independent of parsing.
@frozen
public struct Map<
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & ~Escapable,
    Failure: Swift.Error
> {

    public let transform: @_lifetime(captures, copy source)
        (_ source: consuming Source) throws(Failure) -> Target

    @inlinable
    public init(
        _ transform: @escaping @_lifetime(captures, copy source)
            (_ source: consuming Source) throws(Failure) -> Target
    ) {
        self.transform = transform
    }

    @inlinable
    @_lifetime(borrow self, copy source)
    public borrowing func callAsFunction(_ source: consuming Source) throws(Failure) -> Target {
        try transform(source)
    }
}

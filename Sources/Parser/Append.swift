/// An operation that appends a value to an accumulated value.
///
/// The result may have a different type from either operand. For example,
/// appending to a heterogeneous tuple increases its arity, while appending
/// an element to an array preserves the array type.
///
/// Unlike a semigroup operation, append need not be closed over one type.
/// This witness does not impose associativity or an identity element.
/// Use `Failure == Never` for an operation that cannot fail.
///
/// A nonescapable result inherits both operands' lifetime dependencies and
/// may also borrow from the stored operation's captures. The witness itself
/// remains escapable; its escaping operation cannot capture scoped values.
@frozen
public struct Append<
    Accumulated: ~Copyable & ~Escapable,
    Next: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable,
    Failure: Swift.Error
> {

    public let appending: @_lifetime(captures, copy accumulated, copy next)
        (_ accumulated: consuming Accumulated, _ next: consuming Next) throws(Failure) -> Output

    @inlinable
    public init(
        appending: @escaping @_lifetime(captures, copy accumulated, copy next)
        (_ accumulated: consuming Accumulated, _ next: consuming Next) throws(Failure) -> Output
    ) {
        self.appending = appending
    }

    /// Transfers both operands to the operation while keeping the witness reusable.
    @inlinable
    @_lifetime(borrow self, copy accumulated, copy next)
    public borrowing func callAsFunction(
        _ accumulated: consuming Accumulated,
        _ next: consuming Next
    ) throws(Failure) -> Output {
        try appending(accumulated, next)
    }
}

extension Append where Failure == Never {

    /// Appends one value to a heterogeneous tuple without nesting that tuple.
    ///
    /// This pack-based convenience uses copyable, escapable elements and cannot
    /// fail. Use `init(appending:)` for other ownership or failure requirements.
    @inlinable
    public init<each Element>()
    where
        Accumulated == (repeat each Element),
        Output == (repeat each Element, Next),
        Next: Copyable & Escapable
    {
        self.init { accumulated, next in
            (repeat each accumulated, next)
        }
    }
}

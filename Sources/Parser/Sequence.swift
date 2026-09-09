/// A group represented by a single composed body.
///
/// The body describes the contents; a domain adapter determines how to execute
/// them. This grouping type is distinct from the standard library's iteration
/// protocol, `Swift.Sequence`.
@frozen
public struct Sequence<Body: ~Copyable & ~Escapable>: ~Copyable, ~Escapable {

    public let body: Body

    @inlinable
    @_lifetime(copy body)
    public init(_ body: consuming Body) {
        self.body = body
    }
}

extension Sequence: Copyable where Body: Copyable & ~Escapable {}
extension Sequence: Escapable where Body: ~Copyable & Escapable {}

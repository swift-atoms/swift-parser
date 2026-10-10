#if Choice
public import Checkpoint

public struct Not<Upstream: Parsing>: Parsing
where Upstream.Input: Restorable & ~Copyable & ~Escapable, Upstream.Output: ~Copyable & ~Escapable {
    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("\(Self.self) is a leaf parser: implement parse(_:) directly")
        }
    }

    public typealias Input = Upstream.Input
    public typealias Output = Void
    public typealias Failure = Error
    public enum Error: Swift.Error { case unexpectedMatch; case upstream(Upstream.Failure) }
    public let upstream: Upstream
    public let rejected: (Upstream.Failure) -> Bool
    public init(_ upstream: Upstream, rejected: @escaping (Upstream.Failure) -> Bool) {
        self.upstream = upstream; self.rejected = rejected
    }
    public borrowing func parse(_ input: inout Input) throws(Error) {
        let saved = input.checkpoint
        do throws(Upstream.Failure) { _ = try upstream.parse(&input) } catch {
            guard rejected(error) else { throw .upstream(error) }
            input.seek(to: saved)
            return
        }
        input.seek(to: saved)
        throw .unexpectedMatch
    }
}
extension Parsing where Input: Restorable & ~Copyable & ~Escapable, Output: ~Copyable & ~Escapable {
    public func not(rejected: @escaping (Failure) -> Bool) -> Not<Self> { .init(self, rejected: rejected) }
}
#endif

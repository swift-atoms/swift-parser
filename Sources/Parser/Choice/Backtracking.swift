#if Choice
public import Checkpoint

public struct Backtracking<Upstream: Parsing>: Parsing
where Upstream.Input: Restorable & ~Copyable & ~Escapable,
      Upstream.Output: ~Copyable & Escapable {

    public typealias Input = Upstream.Input
    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure
    public let upstream: Upstream
    public init(_ upstream: Upstream) { self.upstream = upstream }
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        let saved = input.checkpoint
        do throws(Failure) { return try upstream.parse(&input) } catch {
            input.seek(to: saved)
            throw error
        }
    }
}

extension Parsing where Input: Restorable & ~Copyable & ~Escapable, Output: ~Copyable & Escapable {
    public func backtracking() -> Backtracking<Self> { Backtracking(self) }
}
#endif

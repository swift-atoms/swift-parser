#if Choice
public import Checkpoint

public struct Optionally<Wrapped: Parsing>: Parsing
where Wrapped.Input: Restorable & ~Copyable & ~Escapable, Wrapped.Output: ~Copyable & Escapable {

    public typealias Input = Wrapped.Input
    public typealias Output = Wrapped.Output?
    public typealias Failure = Wrapped.Failure
    public let wrapped: Wrapped
    public let rejected: (Failure) -> Bool
    public init(_ wrapped: Wrapped, rejected: @escaping (Failure) -> Bool) {
        self.wrapped = wrapped; self.rejected = rejected
    }
    public init(rejected: @escaping (Failure) -> Bool, @Builder<Wrapped.Input> _ wrapped: () -> Wrapped) {
        self.init(wrapped(), rejected: rejected)
    }
    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        let saved = input.checkpoint
        do throws(Failure) { return try wrapped.parse(&input) } catch {
            guard rejected(error) else { throw error }
            input.seek(to: saved)
            return nil
        }
    }
}
#endif

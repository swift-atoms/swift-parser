#if Repetition
public import Cardinal
public import Repetition
public import Either
public import Checkpoint

extension Cardinal.Range {
    public func parser<P: Parsing & ~Copyable, Rejection: Swift.Error, Fatal: Swift.Error>(
        _ build: () -> P
    ) -> Repetition<Self, P>.Parser<Rejection, Fatal>
    where P.Input: Restorable & ~Copyable & ~Escapable, P.Input.Checkpoint: Equatable,
          P.Output: Copyable & Escapable, P.Failure == Either<Rejection, Fatal> {
        .init(.init(self, operation: build()))
    }
    public func parser<Input: Restorable & ~Copyable & ~Escapable, P: Parsing & ~Copyable, Rejection: Swift.Error, Fatal: Swift.Error>(
        for input: Input.Type, @Builder<Input> _ build: () -> P
    ) -> Repetition<Self, P>.Parser<Rejection, Fatal>
    where Input.Checkpoint: Equatable, P.Input == Input, P.Input: ~Copyable & ~Escapable,
          P.Output: Copyable & Escapable, P.Failure == Either<Rejection, Fatal> {
        .init(.init(self, operation: build()))
    }
}
#endif

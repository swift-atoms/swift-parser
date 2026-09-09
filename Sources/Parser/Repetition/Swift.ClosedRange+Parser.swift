#if Repetition
public import Cardinal
public import Repetition
public import Either
public import Checkpoint

extension Swift.ClosedRange where Bound == Cardinal {
    public typealias Parser<P: Parsing & ~Copyable, Rejection: Swift.Error, Fatal: Swift.Error> = Repetition<Self, P>.Parser<Rejection, Fatal>
    where P.Input: Restorable & ~Copyable & ~Escapable, P.Input.Checkpoint: Equatable,
          P.Output: Copyable & Escapable, P.Failure == Either<Rejection, Fatal>
}
#endif

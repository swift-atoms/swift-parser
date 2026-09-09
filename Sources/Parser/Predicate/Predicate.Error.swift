#if Predicate
public import Predicate

extension Predicate where T: ~Copyable & ~Escapable {
    /// Failure to obtain one input element satisfying the predicate.
    public enum Error: Swift.Error, Equatable {
        case empty
        case rejected
    }
}

#endif

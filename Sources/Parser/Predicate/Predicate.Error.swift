#if Predicate
public import Predicate

extension Predicate where T: ~Copyable & ~Escapable {

    public enum Error: Swift.Error, Equatable {
        case empty
        case rejected
    }
}

#endif

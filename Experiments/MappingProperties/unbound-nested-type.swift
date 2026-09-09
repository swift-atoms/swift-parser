struct Map<S, T, E: Error> {
    struct Parser<P> { let upstream: P }
}
struct Source {
    var map: Map.Parser<Self> { .init(upstream: self) }
}

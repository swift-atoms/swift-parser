#if Product
struct Candidate<
    each Element: ~Copyable & ~Escapable
>: ~Copyable, ~Escapable {
    var values: (repeat each Element)
}
#endif

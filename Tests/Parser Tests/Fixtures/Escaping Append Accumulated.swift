import Parser

struct Joined: ~Copyable, ~Escapable {
    let first: Span<Int>
    let second: Span<Int>

    @_lifetime(copy first, copy second)
    init(_ first: consuming Span<Int>, _ second: consuming Span<Int>) {
        self.first = first
        self.second = second
    }
}

@_lifetime(borrow append, copy other)
func escape(
    _ append: borrowing Append<Span<Int>, Span<Int>, Joined, Never>,
    _ other: consuming Span<Int>
) -> Joined {
    let local = [1, 2]
    return append(local.span, other)
}

// Reusing Self preserves the spelling, but loses which operation was selected.
struct P {
    var map: Self { self }
    var flatMap: Self { self }
    func callAsFunction<T>(_ transform: (Int) -> T) -> String { "map" }
    func callAsFunction(_ transform: (Int) -> P) -> String { "flatMap" }
}
assert(P().map { $0 + 1 } == "map")
assert(P().flatMap { _ in P() } == "flatMap")
// A map is allowed to produce a parser as an ordinary value. This is wrong:
assert(P().map { _ in P() } == "flatMap")
// flatMap also incorrectly accepts a non-parser result:
assert(P().flatMap { $0 + 1 } == "map")
print("Self reuse compiles, but map and flatMap have identical dispatch")

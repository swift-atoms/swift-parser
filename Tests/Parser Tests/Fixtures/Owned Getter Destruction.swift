nonisolated(unsafe) var destroyed = 0
protocol Token: ~Copyable {}
struct Owner: Token, ~Copyable {
    deinit { destroyed += 1 }
}
struct Bound<Base: ~Copyable>: ~Copyable {
    let base: Base
    init(_ base: consuming Base) { self.base = base }
}
extension Token where Self: ~Copyable {
    @_owned var bound: Bound<Self> {
        consuming get { Bound(consume self) }
    }
}
func discard<T: ~Copyable>(_ value: consuming T) {}
func run() {
    let owner = Owner()
    let bound = (consume owner).bound
    print("Before discarding bound:", destroyed)
    discard(bound)
    print("After discarding bound:", destroyed)
}
run()

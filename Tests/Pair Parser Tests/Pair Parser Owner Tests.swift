#if Pair && Append && Skip && Map && FlatMap
import Parser
import Either
import Pair
import Testing

private final class Lifetime {
    var owners: [Int] = []
    var values: [Int] = []
}
private struct Value: ~Copyable, Parsing {
    enum Error: Swift.Error, Equatable { case rejected(Int) }
    let id: Int
    let life: Lifetime
    var fail = false
    deinit { life.owners.append(id) }
    borrowing func parse(_ input: inout Int) throws(Error) -> Int {
        input += 1
        if fail { throw .rejected(id) }
        return input
    }
}
private struct Marker: ~Copyable, Parsing {
    enum Error: Swift.Error, Equatable { case rejected(Int) }
    let id: Int
    let life: Lifetime
    var fail = false
    deinit { life.owners.append(id) }
    borrowing func parse(_ input: inout Int) throws(Error) {
        input += 1
        if fail { throw .rejected(id) }
    }
}
private struct Token: ~Copyable {
    let value: Int
    let life: Lifetime
    deinit { life.values.append(value) }
}
private struct TokenParser: ~Copyable, Parsing {
    let id: Int
    let life: Lifetime
    var fail = false
    deinit { life.owners.append(id) }
    borrowing func parse(_ input: inout Int) throws(Value.Error) -> Token {
        input += 1
        if fail { throw .rejected(id) }
        return Token(value: input, life: life)
    }
}
private struct OtherTokenParser: ~Copyable, Parsing {
    let id: Int
    let life: Lifetime
    var fail = false
    deinit { life.owners.append(id) }
    borrowing func parse(_ input: inout Int) throws(Marker.Error) -> Token {
        input += 1
        if fail { throw .rejected(id) }
        return Token(value: input, life: life)
    }
}
private struct CopyValue: Parsing {
    borrowing func parse(_ input: inout Int) -> Int { input += 1; return input }
}
private struct CopyTokenParser: Parsing {
    let life: Lifetime
    borrowing func parse(_ input: inout Int) -> Token {
        input += 1
        return Token(value: input, life: life)
    }
}
private struct CopyMarker: Parsing {
    borrowing func parse(_ input: inout Int) { input += 1 }
}
private func discard<T: ~Copyable>(_ value: consuming T) {}
private func requireCopyable<T: Copyable>(_ value: T) {}
private func requireAppend<A: Parsing & ~Copyable, N: Parsing & ~Copyable, F: Swift.Error, each O>(
    _: borrowing Append::Append<A.Output, N.Output, (repeat each O, N.Output), Never>.Parser<A, N, F>
) where A.Input == N.Input, A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable, A.Output == (repeat each O) {}
private func requireSkip<A: Parsing & ~Copyable, N: Parsing & ~Copyable, F: Swift.Error>(
    _: borrowing Skip::Skip<A.Output, N.Output>.Parser<A, N, F>
) where A.Input == N.Input, A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable, A.Output: ~Copyable & Escapable, N.Output == Void {}
private func requirePair<A: Parsing & ~Copyable, N: Parsing & ~Copyable, F: Swift.Error>(
    _: borrowing Pair<A, N>.Parser<F>
) where A.Input == N.Input, A.Input: ~Copyable & ~Escapable, N.Input: ~Copyable & ~Escapable, A.Output: ~Copyable & Escapable, N.Output: ~Copyable & Escapable {}

@Suite
struct `Parser sequences preserve noncopyable owners across tuple and Pair composition` {
    @Test
    func `fresh owners retain flat tuple append and skipped marker semantics`() throws {
        let life = Lifetime()
        let p = build {
            Value(id: 1, life: life)
            Marker(id: 2, life: life)
            Value(id: 3, life: life)
            Marker(id: 4, life: life)
        }
        requireSkip(p)
        requireAppend(p.accumulated)
        var input = 0
        let first = try p.parse(&input)
        let second = try p.parse(&input)
        #expect(first == (1, 3))
        #expect(second == (5, 7))
        #expect(input == 8)
        #expect(life.owners.isEmpty)
        discard(p)
        #expect(life.owners.sorted() == [1, 2, 3, 4])
    }
    @Test
    func `fresh token owners retain left nested Pair results and shared failure`() throws {
        let life = Lifetime()
        let p = build {
            TokenParser(id: 1, life: life)
            TokenParser(id: 2, life: life)
            TokenParser(id: 3, life: life)
        }
        requirePair(p)
        var input = 0
        let first = try p.parse(&input)
        #expect(first.first.first.value == 1)
        #expect(first.first.second.value == 2)
        #expect(first.second.value == 3)
        discard(first)
        let second = try p.parse(&input)
        #expect(second.first.first.value == 4)
        #expect(second.first.second.value == 5)
        #expect(second.second.value == 6)
        discard(second)
        #expect(life.values.sorted() == [1, 2, 3, 4, 5, 6])
        #expect(life.owners.isEmpty)
        discard(p)
        #expect(life.owners.sorted() == [1, 2, 3])
    }
    @Test(arguments: [1, 2, 3])
    func `tuple failures preserve nested branches and exact consumption`(_ failed: Int) {
        let life = Lifetime()
        let p = build {
            Value(id: 1, life: life, fail: failed == 1)
            Marker(id: 2, life: life, fail: failed == 2)
            Value(id: 3, life: life, fail: failed == 3)
        }
        var input = 0
        do {
            _ = try p.parse(&input)
            Issue.record("expected failure")
        } catch {
            switch (failed, error) {
            case (1, .left(.left(.rejected(1)))): break
            case (2, .left(.right(.rejected(2)))): break
            case (3, .right(.rejected(3))): break
            default: Issue.record("wrong failure branch")
            }
        }
        #expect(input == failed)
        #expect(life.owners.isEmpty)
        discard(p)
        #expect(life.owners.sorted() == [1, 2, 3])
    }
    @Test(arguments: [1, 2, 3])
    func `Pair failures destroy prior results and retain owners`(_ failed: Int) {
        let life = Lifetime()
        let p = build {
            TokenParser(id: 1, life: life, fail: failed == 1)
            OtherTokenParser(id: 2, life: life, fail: failed == 2)
            TokenParser(id: 3, life: life, fail: failed == 3)
        }
        var input = 0
        do {
            let output = try p.parse(&input)
            discard(output)
            Issue.record("expected failure")
        } catch {
            switch (failed, error) {
            case (1, .left(.left(.rejected(1)))): break
            case (2, .left(.right(.rejected(2)))): break
            case (3, .right(.rejected(3))): break
            default: Issue.record("wrong failure branch")
            }
        }
        #expect(input == failed)
        #expect(life.values.sorted() == Array(1..<failed))
        #expect(life.owners.isEmpty)
        discard(p)
        #expect(life.owners.sorted() == [1, 2, 3])
    }
    @Test
    func `copyable owners preserve checked Copyable sequences with tuple and Pair outputs`() {
        let tuple = build { CopyValue(); CopyMarker(); CopyValue() }
        requireCopyable(tuple)
        requireAppend(tuple)
        let tupleCopy = tuple
        var input = 0
        #expect(tuple.parse(&input) == (1, 3))
        #expect(tupleCopy.parse(&input) == (4, 6))
        let life = Lifetime()
        let pair = build { CopyTokenParser(life: life); CopyTokenParser(life: life) }
        requireCopyable(pair)
        requirePair(pair)
        let pairCopy = pair
        discard(pair.parse(&input))
        discard(pairCopy.parse(&input))
        #expect(life.values.sorted() == [7, 8, 9, 10])
    }
    @Test
    func `a noncopyable result followed by Void keeps the existing Pair shape`() throws {
        let life = Lifetime()
        let p = build { TokenParser(id: 1, life: life); Marker(id: 2, life: life) }
        requirePair(p)
        var input = 0
        let result = try p.parse(&input)
        #expect(result.first.value == 1)
        #expect(input == 2)
        discard(result)
        discard(p)
        #expect(life.values == [1])
        #expect(life.owners.sorted() == [1, 2])
    }
}

@Suite
struct `Pair parsers consume both stored owners` {
    @Test
    func `consuming a Pair transfers both owners and preserves a shared failure`() throws {
        let life = Lifetime()
        let owners = Pair(TokenParser(id: 1, life: life), TokenParser(id: 2, life: life, fail: true))
        let p = owners.parser()
        var input = 0
        do {
            let result = try p.parse(&input)
            discard(result)
            Issue.record("expected failure")
        } catch {
            let failure: Value.Error = error
            #expect(failure == .rejected(2))
        }
        #expect(input == 2)
        #expect(life.values == [1])
        #expect(life.owners.isEmpty)
        discard(p)
        #expect(life.owners.sorted() == [1, 2])
    }
}

private func build<P: Parsing & ~Copyable>(
    @Parser::Builder<Int> _ make: () -> P
) -> P
where P.Input == Int, P.Output: ~Copyable & ~Escapable {
    make()
}

#endif

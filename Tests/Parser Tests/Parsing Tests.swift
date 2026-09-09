import Parser
import Testing

@Suite
struct `Parsing forwards expressive bodies to their operations` {
    @Test
    func `a leaf implements parsing directly`() throws {
        var input: Substring = "abc"
        let output = try Literal("a").parse(&input)
        #expect(output == "a")
        #expect(input == "bc")
    }

    @Test
    func `a computed body composes through the inferred result builder`() throws {
        var input: Substring = "abc"
        let output = try Prefix().parse(&input)
        #expect(output == "a")
        #expect(input == "bc")
    }

    @Test
    func `a computed body preserves its typed failure`() {
        var input: Substring = "bc"
        #expect(throws: LiteralError.expected("a")) {
            try Prefix().parse(&input)
        }
        #expect(input == "bc")
    }
}

private enum LiteralError: Swift.Error, Equatable {
    case expected(Character)
}

private struct Literal: Parsing {
    let expected: Character

    init(_ expected: Character) {
        self.expected = expected
    }

    borrowing func parse(_ input: inout Substring) throws(LiteralError) -> Character {
        guard input.first == expected else { throw .expected(expected) }
        input = input.dropFirst()
        return expected
    }
}

private struct Prefix: Parsing {
    var body: some Parsing<Substring, Character, LiteralError> {
        Literal("a")
    }
}

@Suite
struct `Parser bodies preserve noncopyable stored owners` {

    @Test
    func `default body forwarding borrows a stored noncopyable owner`() throws {
        let lifetime = Lifetime()
        let parser = BodyOwner(lifetime)
        var input = 0

        #expect(try parser.parse(&input) == 1)
        #expect(try parser.parse(&input) == 2)
        #expect(lifetime.destroyed == 0)

        discard(parser)

        #expect(lifetime.destroyed == 1)
    }
}

private final class Lifetime {
    var destroyed = 0
}

private struct Value: ~Copyable, Parsing {
    enum Error: Swift.Error { case rejected }

    let lifetime: Lifetime

    deinit { lifetime.destroyed += 1 }

    borrowing func parse(_ input: inout Int) throws(Error) -> Int {
        input += 1
        return input
    }
}

private struct BodyOwner: ~Copyable, Parsing {
    let body: Value

    init(_ lifetime: Lifetime) {
        body = Value(lifetime: lifetime)
    }
}

private func discard<T: ~Copyable>(_ value: consuming T) {}

extension `Parsing forwards expressive bodies to their operations` {
    @Test
    func `body inference preserves scoped noncopyable input and typed failure`() throws {
        let values = [7]
        var input = ScopedInput(values.span)
        let parser = ScopedBody()

        #expect(try parser.parse(&input) == 7)
        do {
            _ = try parser.parse(&input)
            Issue.record("Expected exhausted input")
        } catch {
            #expect(error == .exhausted)
        }
    }
}

private struct ScopedInput: ~Copyable, ~Escapable {
    let values: Span<Int>
    var position = 0

    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}

private enum ScopedFailure: Error, Equatable { case exhausted }

private struct ScopedBody: Parsing {
    var body: some Parsing<ScopedInput, Int, ScopedFailure> {
        Parser<ScopedInput, Int, ScopedFailure> { input throws(ScopedFailure) in
            guard input.position < input.values.count else { throw .exhausted }
            defer { input.position += 1 }
            return input.values[input.position]
        }
    }
}

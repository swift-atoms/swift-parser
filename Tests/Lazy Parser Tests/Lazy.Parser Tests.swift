#if Lazy
import Lazy
import Parser
import Testing

@Suite
struct `Lazy Parser Tests` {

    @Test
    func `defers parser construction until parse time`() throws(any Swift.Error) {
        final class Box {
            var built = 0
        }
        let box = Box()

        let lazy = Lazy {
            box.built += 1
            return Literal("a")
        }
        #expect(box.built == 0)

        var input: Substring = "abc"
        let output = try lazy.parser().parse(&input)

        #expect(output == "a")
        #expect(input == "bc")
        #expect(box.built == 1)
    }

    @Test
    func `re-invokes the thunk on every parse`() throws(any Swift.Error) {
        final class Box {
            var built = 0
        }
        let box = Box()

        let lazy = Lazy {
            box.built += 1
            return Literal("a")
        }

        var input: Substring = "aa"
        _ = try lazy.parser().parse(&input)
        _ = try lazy.parser().parse(&input)

        #expect(box.built == 2)
        #expect(input.isEmpty)
    }

    @Test
    func `propagates the wrapped parser's failure`() {
        let lazy = Lazy(Literal("a"))
        var input: Substring = "b"

        #expect(throws: LiteralError.expected("a")) {
            try lazy.parser().parse(&input)
        }
    }
}

private enum LiteralError: Error, Equatable {
    case expected(Character)
}

private struct Literal: Parsing {
    typealias Input = Substring
    typealias Output = Character
    typealias Failure = LiteralError

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

private struct Deferred: Parsing {
    typealias Failure = LiteralError
    var body: some Parsing<Substring, Character, LiteralError> {
        Lazy(Literal("a"))
    }
}

extension `Lazy Parser Tests` {
    @Test func `a body adapts a lazy value`() throws {
        var input: Substring = "abc"
        #expect(try Deferred().parse(&input) == "a")
        #expect(input == "bc")
    }
}

private final class Lifetime {
    var built = 0
    var destroyed = 0
}

private struct Owned: Parsing, ~Copyable {
    typealias Input = Substring
    typealias Output = Int
    typealias Failure = Never
    let lifetime: Lifetime
    deinit { lifetime.destroyed += 1 }
    func parse(_ input: inout Substring) -> Int { input.count }
}

private struct DeferredOwner: Parsing {
    let lifetime: Lifetime
    var body: some Parsing<Substring, Int, Never> {
        Lazy {
            lifetime.built += 1
            return Owned(lifetime: lifetime)
        }
    }
}

extension `Lazy Parser Tests` {
    @Test func `a lazy factory creates and destroys a fresh noncopyable parser per call`() {
        let lifetime = Lifetime()
        let parser = Parser { DeferredOwner(lifetime: lifetime) }
        var input: Substring = "abc"
        #expect(lifetime.built == 0)
        #expect(parser.parse(&input) == 3)
        #expect(lifetime.built == 1)
        #expect(lifetime.destroyed == 1)
        #expect(parser.parse(&input) == 3)
        #expect(lifetime.built == 2)
        #expect(lifetime.destroyed == 2)
    }
}

private enum FactoryError: Error, Equatable { case unavailable }

extension `Lazy Parser Tests` {
    @Test func `factory failure preserves input and the next parse retries construction`() throws {
        var attempts = 0
        let lazy = Lazy { () throws(FactoryError) -> Literal in
            attempts += 1
            if attempts == 1 { throw .unavailable }
            return Literal("a")
        }
        let parser = Parser { lazy }
        var input: Substring = "ab"
        #expect(throws: Either<FactoryError, LiteralError>.left(.unavailable)) {
            try parser.parse(&input)
        }
        #expect(input == "ab")
        #expect(attempts == 1)
        #expect(try parser.parse(&input) == "a")
        #expect(input == "b")
        #expect(attempts == 2)
        #expect(throws: Either<FactoryError, LiteralError>.right(.expected("a"))) {
            try parser.parse(&input)
        }
        #expect(attempts == 3)
        #expect(input == "b")
    }

    @Test func `throwing factory transfers a noncopyable parser and preserves typed errors`() throws {
        let lifetime = Lifetime()
        let lazy = Lazy { () throws(FactoryError) -> Owned in
            lifetime.built += 1
            return Owned(lifetime: lifetime)
        }
        let parser: Lazy<Owned, FactoryError>.Parser<Either<FactoryError, Never>> = lazy.parser()
        var input: Substring = "abc"
        #expect(try parser.parse(&input) == 3)
        #expect(lifetime.built == 1)
        #expect(lifetime.destroyed == 1)
    }

    @Test func `infallible factories retain the parser failure type`() {
        let lazy = Lazy(Literal("a"))
        let parser: Lazy<Literal, Never>.Parser<LiteralError> = lazy.parser()
        var input: Substring = "b"
        #expect(throws: LiteralError.expected("a")) { try parser.parse(&input) }
    }
}
#endif

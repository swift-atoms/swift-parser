import Parser
import Testing

@Suite
struct `Error mapping preserves parser ownership` {
    @Test
    func `a noncopyable leaf supports repeated borrowed execution and one destruction`() throws {
        let lifetime = Lifetime()
        let parser = Owned(lifetime: lifetime)
        var input = 0
        let first = try parser.parse(&input)
        #expect(first == 1)
        do throws(Owned.Error) {
            _ = try parser.parse(&input)
            Issue.record("The leaf unexpectedly accepted its second input")
        } catch {
            #expect(error == .rejected(2))
        }
        #expect(input == 2)
        #expect(lifetime.destroyed == 0)
        discard(parser)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `explicit error transforms compose noncopyable owners and preserve consumption`() throws {
        let lifetime = Lifetime()
        let firstMap = Parser.Error.Transform(Owned(lifetime: lifetime)).map { error -> Mapped in
            lifetime.mapped += 1
            return .upstream(error)
        }
        let parser = Parser.Error.Transform(firstMap).map { error -> Mapped in error }
        requireFailure(parser, Mapped.self)
        var input = 0

        let first = try parser.parse(&input)
        #expect(first == 1)
        #expect(lifetime.mapped == 0)
        do throws(Mapped) {
            _ = try parser.parse(&input)
            Issue.record("Error mapping unexpectedly accepted the rejected input")
        } catch {
            #expect(error == .upstream(.rejected(2)))
        }
        #expect(input == 2)
        #expect(lifetime.mapped == 1)
        let third = try parser.parse(&input)
        #expect(third == 3)
        #expect(lifetime.destroyed == 0)
        discard(parser)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `error mapping composes with an existing noncopyable value map`() throws {
        let lifetime = Lifetime()
        let upstream = Owned(lifetime: lifetime).map { $0 * 2 }
        let parser = Parser.Error.Transform(upstream).map { Mapped.upstream($0) }
        var input = 0
        let first = try parser.parse(&input)
        #expect(first == 2)
        do throws(Mapped) {
            _ = try parser.parse(&input)
            Issue.record("The mapped parser unexpectedly accepted the rejected input")
        } catch {
            #expect(error == .upstream(.rejected(2)))
        }
        #expect(input == 2)
        discard(parser)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `error mapping keeps a scoped output tied to the borrowed owner`() throws {
        let lifetime = Lifetime()
        try inspectScopedOutput(lifetime)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `fluent error access preserves copyable transforms and maps for copyable owners`() throws {
        let upstream = Parser.Witness<Int, Int, Owned.Error> { $0 }
        let transform = upstream.error
        requireCopyable(transform)
        let mapped = transform.map { Mapped.upstream($0) }
        requireCopyable(mapped)
        var input = 7
        let original = try upstream.parse(&input)
        let remapped = try mapped.parse(&input)
        #expect(original == 7 && remapped == 7)
    }
}

private func inspectScopedOutput(_ lifetime: Lifetime) throws {
    let parser = Parser.Error.Transform(Scoped(lifetime: lifetime)).map { Mapped.upstream($0) }
    var input = 0
    let output = try parser.parse(&input)
    #expect(lifetime.destroyed == 0)
    #expect(output.count == 2)
    #expect(output[0] == 4 && output[1] == 9)
}

private func requireFailure<P: Parser.`Protocol` & ~Copyable, E: Swift.Error>(
    _: borrowing P,
    _: E.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == E {}

private func requireCopyable<T: Copyable>(_: T) {}

private func discard<T: ~Copyable>(_ value: consuming T) {}

private enum Mapped: Swift.Error, Equatable {
    case upstream(Owned.Error)
}

private final class Lifetime {
    var destroyed = 0
    var mapped = 0
}

private struct Owned: ~Copyable, Parser.`Protocol` {
    let lifetime: Lifetime

    enum Error: Swift.Error, Equatable {
        case rejected(Int)
    }

    deinit { lifetime.destroyed += 1 }

    borrowing func parse(_ input: inout Int) throws(Error) -> Int {
        input += 1
        guard input != 2 else { throw .rejected(input) }
        return input
    }
}

private struct Scoped: ~Copyable, Parser.`Protocol` {
    let lifetime: Lifetime
    let values = [4, 9]

    deinit { lifetime.destroyed += 1 }

    @_lifetime(borrow self)
    borrowing func parse(_ input: inout Int) throws(Owned.Error) -> Span<Int> {
        values.span
    }
}

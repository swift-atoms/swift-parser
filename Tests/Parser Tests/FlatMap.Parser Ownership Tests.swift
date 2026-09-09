import Either
import Parser
import Testing

@Suite
struct `Direct and fluent flat map preserve noncopyable results` {
    @Test(arguments: [false, true])
    func `successful results remain alive until consumed and are destroyed once`(_ fluent: Bool) throws {
        let lifetime = Lifetime()
        let parser = makeParser(fluent: fluent, lifetime: lifetime)
        requireFailure(parser, Either<Seed.Error, Finish.Error>.self)
        requireCopyable(parser)
        var input = 10

        let output = try parser.parse(&input)

        #expect(input == 13)
        #expect(output.value == 24)
        #expect(lifetime.transforms == 1)
        #expect(lifetime.created == [.upstream, .downstream])
        #expect(lifetime.destroyed == [.upstream])

        let value = consumeValue(output)
        #expect(value == 24)
        #expect(lifetime.destroyed == [.upstream, .downstream])
    }

    @Test(arguments: [false, true])
    func `upstream failure retains consumption and destroys its temporary value once`(_ fluent: Bool) {
        let lifetime = Lifetime()
        let parser = makeParser(fluent: fluent, failing: .upstream, lifetime: lifetime)
        var input = 10

        do throws(Either<Seed.Error, Finish.Error>) {
            let output = try parser.parse(&input)
            _ = consumeValue(output)
            Issue.record("Upstream failure unexpectedly succeeded")
        } catch {
            #expect(error == .left(.rejected(11)))
        }

        #expect(input == 11)
        #expect(lifetime.transforms == 0)
        #expect(lifetime.created == [.upstream])
        #expect(lifetime.destroyed == [.upstream])
    }

    @Test(arguments: [false, true])
    func `downstream failure retains both stages of consumption and destroys each value once`(_ fluent: Bool) {
        let lifetime = Lifetime()
        let parser = makeParser(fluent: fluent, failing: .downstream, lifetime: lifetime)
        var input = 10

        do throws(Either<Seed.Error, Finish.Error>) {
            let output = try parser.parse(&input)
            _ = consumeValue(output)
            Issue.record("Downstream failure unexpectedly succeeded")
        } catch {
            #expect(error == .right(.rejected(13)))
        }

        #expect(input == 13)
        #expect(lifetime.transforms == 1)
        #expect(lifetime.created == [.upstream, .downstream])
        #expect(lifetime.destroyed == [.upstream, .downstream])
    }
}

private func makeParser(
    fluent: Bool,
    failing: Stage? = nil,
    lifetime: Lifetime
) -> Parser::FlatMap<Seed.Output, Finish>.Parser<Seed> {
    let upstream = Seed(fails: failing == .upstream, lifetime: lifetime)
    let transform: (consuming LinearValue) -> Finish = { (value: consuming LinearValue) in
        lifetime.transforms += 1
        return Finish(seed: value.value, fails: failing == .downstream, lifetime: lifetime)
    }
    if fluent {
        return upstream.flatMap(transform)
    }
    return Parser::FlatMap.Parser(upstream: upstream, transform: transform)
}

private func requireFailure<P: Parser.`Protocol` & ~Copyable, E: Swift.Error>(
    _: borrowing P,
    _: E.Type
) where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == E {}

private func requireCopyable<T: Copyable>(_: T) {}

private func consumeValue(_ value: consuming LinearValue) -> Int {
    value.value
}

private enum Stage {
    case upstream
    case downstream
}

private final class Lifetime {
    var created: [Stage] = []
    var destroyed: [Stage] = []
    var transforms = 0
}

private struct LinearValue: ~Copyable {
    let value: Int
    let stage: Stage
    let lifetime: Lifetime

    init(value: Int, stage: Stage, lifetime: Lifetime) {
        self.value = value
        self.stage = stage
        self.lifetime = lifetime
        lifetime.created.append(stage)
    }

    deinit {
        lifetime.destroyed.append(stage)
    }
}

private struct Seed: Parser.`Protocol` {
    let fails: Bool
    let lifetime: Lifetime

    enum Error: Swift.Error, Equatable {
        case rejected(Int)
    }

    borrowing func parse(_ input: inout Int) throws(Error) -> LinearValue {
        input += 1
        let output = LinearValue(value: input, stage: .upstream, lifetime: lifetime)
        guard !fails else { throw .rejected(input) }
        return output
    }
}

private struct Finish: Parser.`Protocol` {
    let seed: Int
    let fails: Bool
    let lifetime: Lifetime

    enum Error: Swift.Error, Equatable {
        case rejected(Int)
    }

    borrowing func parse(_ input: inout Int) throws(Error) -> LinearValue {
        input += 2
        let output = LinearValue(value: seed + input, stage: .downstream, lifetime: lifetime)
        guard !fails else { throw .rejected(input) }
        return output
    }
}

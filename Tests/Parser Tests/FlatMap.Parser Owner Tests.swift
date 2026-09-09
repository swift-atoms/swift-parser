import Either
import Parser
import Testing

@Suite
struct `Flat map retains its upstream and creates a downstream for each call` {
    @Test(arguments: [false, true])
    func `both construction styles reuse a linear upstream and destroy each downstream once`(_ fluent: Bool) throws {
        let lifetime = Lifetime()
        let parser = makeParser(fluent: fluent, lifetime: lifetime)
        var input = 0

        for expected in [3, 7] {
            let output = try parser.parse(&input)
            #expect(output.number == expected)
            #expect(lifetime.upstreamDestroyed == 0)
            #expect(lifetime.downstreamCreated == lifetime.downstreamDestroyed)
            #expect(lifetime.seedsCreated == lifetime.seedsDestroyed)
            discard(output)
        }

        #expect(input == 4)
        #expect(lifetime.downstreamCreated == 2)
        #expect(lifetime.resultsCreated == 2 && lifetime.resultsDestroyed == 2)
        discard(parser)
        #expect(lifetime.upstreamDestroyed == 1)
    }

    @Test(arguments: [false, true])
    func `upstream failure retains consumption without constructing a downstream`(_ fluent: Bool) {
        let lifetime = Lifetime()
        let parser = makeParser(fluent: fluent, failing: .upstream, lifetime: lifetime)
        var input = 0

        do throws(Either<Remapped, Downstream.Error>) {
            let output = try parser.parse(&input)
            discard(output)
            Issue.record("The upstream unexpectedly succeeded")
        } catch {
            #expect(error == .left(.upstream(.rejected(1))))
        }

        #expect(input == 1)
        #expect(lifetime.errorMaps == 1)
        #expect(lifetime.downstreamCreated == 0)
        #expect(lifetime.downstreamDestroyed == 0)
        #expect(lifetime.seedsCreated == 0)
        #expect(lifetime.upstreamDestroyed == 0)
        discard(parser)
        #expect(lifetime.upstreamDestroyed == 1)
    }

    @Test(arguments: [false, true])
    func `downstream failure destroys its owner and the consumed seed while retaining the upstream`(_ fluent: Bool) {
        let lifetime = Lifetime()
        let parser = makeParser(fluent: fluent, failing: .downstream, lifetime: lifetime)
        var input = 0

        do throws(Either<Remapped, Downstream.Error>) {
            let output = try parser.parse(&input)
            discard(output)
            Issue.record("The downstream unexpectedly succeeded")
        } catch {
            #expect(error == .right(.rejected(2)))
        }

        #expect(input == 2)
        #expect(lifetime.errorMaps == 0)
        #expect(lifetime.downstreamCreated == 1 && lifetime.downstreamDestroyed == 1)
        #expect(lifetime.seedsCreated == 1 && lifetime.seedsDestroyed == 1)
        #expect(lifetime.resultsCreated == 0)
        #expect(lifetime.upstreamDestroyed == 0)
        discard(parser)
        #expect(lifetime.upstreamDestroyed == 1)
    }

    @Test(arguments: [false, true])
    func `a copyable upstream makes the wrapper copyable even when downstream owners are linear`(_ fluent: Bool) throws {
        let lifetime = Lifetime()
        let upstream = Parser.Pure<Int, Int> { input in input += 1; return input }
        let transform = { (number: consuming Int) in
            Downstream(seed: Seed(number: number, lifetime: lifetime), fails: false, lifetime: lifetime)
        }
        let parser: Parser::FlatMap<Parser.Pure<Int, Int>.Output, Downstream>.Parser<Parser.Pure<Int, Int>>
        if fluent {
            parser = upstream.flatMap(transform)
        } else {
            parser = Parser::FlatMap.Parser(upstream: upstream, transform: transform)
        }
        requireCopyable(parser)
        let copied = parser
        var input = 0
        let first = try parser.parse(&input)
        let second = try copied.parse(&input)
        #expect(first.number == 3 && second.number == 7)
        #expect(lifetime.downstreamCreated == 2 && lifetime.downstreamDestroyed == 2)
        discard(first)
        discard(second)
        #expect(lifetime.resultsDestroyed == 2)
    }
}

private func makeParser(
    fluent: Bool,
    failing: Stage? = nil,
    lifetime: Lifetime
) -> Parser::FlatMap<Parser::Map<Upstream.Failure, Remapped, Never>.Error.Parser<Upstream>.Output, Downstream>.Parser<Parser::Map<Upstream.Failure, Remapped, Never>.Error.Parser<Upstream>> {
    let upstream = Upstream(fails: failing == .upstream, lifetime: lifetime).mapFailure { error -> Remapped in
            lifetime.errorMaps += 1
            return .upstream(error)
        }
    let transform: (consuming Seed) -> Downstream = { (seed: consuming Seed) in
        Downstream(seed: seed, fails: failing == .downstream, lifetime: lifetime)
    }
    if fluent {
        return upstream.flatMap(transform)
    }
    return Parser::FlatMap.Parser(upstream: upstream, transform: transform)
}

private func discard<T: ~Copyable>(_ value: consuming T) {}

private func requireCopyable<T: Copyable>(_: T) {}

private enum Stage {
    case upstream
    case downstream
}

private enum Remapped: Swift.Error, Equatable {
    case upstream(Upstream.Error)
}

private final class Lifetime {
    var upstreamDestroyed = 0
    var downstreamCreated = 0
    var downstreamDestroyed = 0
    var seedsCreated = 0
    var seedsDestroyed = 0
    var resultsCreated = 0
    var resultsDestroyed = 0
    var errorMaps = 0
}

private struct Seed: ~Copyable {
    let number: Int
    let lifetime: Lifetime

    init(number: Int, lifetime: Lifetime) {
        self.number = number
        self.lifetime = lifetime
        lifetime.seedsCreated += 1
    }

    deinit { lifetime.seedsDestroyed += 1 }
}

private struct Result: ~Copyable {
    let number: Int
    let lifetime: Lifetime

    init(number: Int, lifetime: Lifetime) {
        self.number = number
        self.lifetime = lifetime
        lifetime.resultsCreated += 1
    }

    deinit { lifetime.resultsDestroyed += 1 }
}

private struct Upstream: ~Copyable, Parser.`Protocol` {
    let fails: Bool
    let lifetime: Lifetime

    enum Error: Swift.Error, Equatable {
        case rejected(Int)
    }

    deinit { lifetime.upstreamDestroyed += 1 }

    borrowing func parse(_ input: inout Int) throws(Error) -> Seed {
        input += 1
        guard !fails else { throw .rejected(input) }
        return Seed(number: input, lifetime: lifetime)
    }
}

private struct Downstream: ~Copyable, Parser.`Protocol` {
    let seed: Seed
    let fails: Bool
    let lifetime: Lifetime

    init(seed: consuming Seed, fails: Bool, lifetime: Lifetime) {
        self.seed = seed
        self.fails = fails
        self.lifetime = lifetime
        lifetime.downstreamCreated += 1
    }

    enum Error: Swift.Error, Equatable {
        case rejected(Int)
    }

    deinit { lifetime.downstreamDestroyed += 1 }

    borrowing func parse(_ input: inout Int) throws(Error) -> Result {
        input += 1
        guard !fails else { throw .rejected(input) }
        return Result(number: seed.number + input, lifetime: lifetime)
    }
}

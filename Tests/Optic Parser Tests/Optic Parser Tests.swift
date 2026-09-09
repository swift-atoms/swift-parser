#if Optic
import Map
import Parser
import Either
import Optic
import Testing

private enum UpstreamFailure: Error, Equatable {
    case upstream
}

private enum TransformFailure: Error, Equatable {
    case transform(Int)
}

private enum BackwardFailure: Error {
    case unused
}

private struct Succeed<Output>: Parsing {
    typealias Input = Void
    typealias Failure = Never

    let output: Output

    borrowing func parse(_ input: inout Void) -> Output {
        output
    }
}

private struct Fail<Output>: Parsing {
    typealias Input = Void
    typealias Failure = UpstreamFailure

    borrowing func parse(_ input: inout Void) throws(UpstreamFailure) -> Output {
        throw .upstream
    }
}

private enum Node: Equatable, Sendable {
    case leaf(Int)
    case empty
}

private struct Digit: RawRepresentable, Equatable, Sendable {
    let rawValue: Int

    init?(rawValue: Int) {
        guard (0...9).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

private struct ScopedToken: ~Copyable, ~Escapable {
    let value: Int
}

private struct Linear: Parsing {
    typealias Input = Int
    typealias Output = ScopedToken
    typealias Failure = Never

    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedToken {
        ScopedToken(value: input)
    }
}

private struct Unmatched: ~Copyable {
    let value: Int
}

private struct UnmatchedParser: Parsing {
    typealias Input = Int
    typealias Output = Unmatched
    typealias Failure = Never

    borrowing func parse(_ input: inout Int) -> Unmatched {
        Unmatched(value: input)
    }
}

private var leaf: Optic<Node, Node, Int, Int>.Prism {
    Optic<Node, Node, Int, Int>.Prism(
        embed: Node.leaf,
        extract: {
            guard case .leaf(let value) = $0 else { return nil }
            return value
        }
    )
}

private var unmatched: Optic<Unmatched, Unmatched, Int, Int>.Prism {
    Optic<Unmatched, Unmatched, Int, Int>.Prism(
        match: { source in .left(source) },
        embed: { Unmatched(value: $0) }
    )
}

@Suite
struct `Optic Parser` {

    @Test
    func `Adapter with two total stages remains exactly nonthrowing`() {
        let adapter = Optic<Int, String, String, Int>.Adapter(
            forward: { String($0) },
            backward: { String($0) }
        )
        let parser = Succeed(output: 42).map(forward: adapter)
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == "42")
    }

    @Test
    func `Adapter ignores backward failure`() {
        let adapter = Optic<Int, String, String, Int>.Adapter(
            forward: { String($0) },
            backward: { _ throws(BackwardFailure) in throw .unused }
        )
        let parser = Succeed(output: 42).map(forward: adapter)
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == "42")
    }

    @Test
    func `Adapter preserves a fallible upstream when forward is total`() {
        let adapter = Optic<Int, String, String, Int>.Adapter(
            forward: { String($0) },
            backward: { String($0) }
        )
        let parser = Fail<Int>().map(forward: adapter)
        requireFailure(parser, UpstreamFailure.self)

        var input: Void = ()
        #expect(throws: UpstreamFailure.upstream) {
            try parser.parse(&input)
        }
    }

    @Test
    func `Adapter uses only forward failure for a nonthrowing upstream`() {
        let adapter = Optic<Int, Int, String, String>.Adapter(
            forward: { value throws(TransformFailure) in throw .transform(value) },
            backward: { Int($0) ?? 0 }
        )
        let parser = Succeed(output: 42).map(forward: adapter)
        requireFailure(parser, TransformFailure.self)

        var input: Void = ()
        #expect(throws: TransformFailure.transform(42)) {
            try parser.parse(&input)
        }
    }

    @Test
    func `Adapter combines two fallible stages with Either`() {
        let adapter = Optic<Int, Int, String, String>.Adapter(
            forward: { value throws(TransformFailure) in throw .transform(value) },
            backward: { Int($0) ?? 0 }
        )
        let parser = Fail<Int>().map(forward: adapter)
        requireFailure(parser, Either<UpstreamFailure, TransformFailure>.self)

        var input: Void = ()
        #expect(throws: Either<UpstreamFailure, TransformFailure>.left(.upstream)) {
            try parser.parse(&input)
        }
    }

    @Test
    func `Adapter forward consumes noncopyable nonescapable parser output`() {
        let adapter = Optic<ScopedToken, Int, Int, Int>.Adapter(
            forward: { token in token.value + 1 },
            backward: { $0 - 1 }
        )
        let parser = Linear().map(forward: adapter)
        requireFailure(parser, Never.self)

        var input = 41
        #expect(parser.parse(&input) == 42)
    }

    @Test
    func `Isomorphism forward adds no failure`() {
        let parser = Succeed(output: Substring("route"))
            .map(forward: String.isomorphisms.substring)
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == "route")
    }

    @Test
    func `Prism lossless matching preserves unmatched target`() {
        let parser = Succeed(output: Node.empty).map(matching: leaf)
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == .left(.empty))
    }

    @Test
    func `RawRepresentable Prism preserves an invalid raw value`() {
        let parser = Succeed(output: 42).map(matching: Digit.prisms.rawValue)
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == .left(42))
    }

    @Test
    func `Prism rejecting matching turns unmatched target into failure`() {
        let parser = Succeed(output: Node.empty).map(
            matching: leaf,
            failure: { node -> TransformFailure in
                switch node {
                case .empty: .transform(0)
                case .leaf(let value): .transform(value)
                }
            }
        )
        requireFailure(parser, TransformFailure.self)

        var input: Void = ()
        #expect(throws: TransformFailure.transform(0)) {
            try parser.parse(&input)
        }
    }

    @Test
    func `Prism rejecting matching consumes a noncopyable target`() {
        let parser = UnmatchedParser().map(
            matching: unmatched,
            failure: { target -> TransformFailure in
                .transform(target.value)
            }
        )
        requireFailure(parser, TransformFailure.self)

        var input = 42
        #expect(throws: TransformFailure.transform(42)) {
            try parser.parse(&input)
        }
    }

    @Test
    func `Prism rejecting matching combines upstream and match failures`() {
        let parser = Fail<Node>().map(
            matching: leaf,
            failure: { _ in TransformFailure.transform(0) }
        )
        requireFailure(parser, Either<UpstreamFailure, TransformFailure>.self)

        var input: Void = ()
        #expect(throws: Either<UpstreamFailure, TransformFailure>.left(.upstream)) {
            try parser.parse(&input)
        }
    }

    @Test
    func `Prism rejecting with an impossible failure preserves upstream failure`() {
        func impossible(_ node: consuming Node) -> Never {
            fatalError("unreachable: upstream fails before Prism matching")
        }

        let parser = Fail<Node>().map(
            matching: leaf,
            failure: impossible
        )
        requireFailure(parser, UpstreamFailure.self)

        var input: Void = ()
        #expect(throws: UpstreamFailure.upstream) {
            try parser.parse(&input)
        }
    }

    @Test
    func `Prism rejecting with two impossible failures remains exactly nonthrowing`() {
        func impossible(_ node: consuming Node) -> Never {
            fatalError("unreachable: the Prism matches")
        }

        let parser = Succeed(output: Node.leaf(7)).map(
            matching: leaf,
            failure: impossible
        )
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == 7)
    }

    @Test
    func `Prism embedding adds no failure`() {
        let parser = Succeed(output: 7).map(embedding: leaf)
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == .leaf(7))
    }

    @Test
    func `Fixed embedding does not inherit reverse mismatch`() {
        let fixed = Optic<Int, Int, Void, Void>.Prism.fixed(42)
        let parser = Succeed(output: ()).map(embedding: fixed)
        requireFailure(parser, Never.self)

        var input: Void = ()
        #expect(parser.parse(&input) == 42)
    }
}

private func requireFailure<P: Parsing, E: Error>(
    _ parser: borrowing P,
    _ failure: E.Type
) where P.Failure == E {}

#endif

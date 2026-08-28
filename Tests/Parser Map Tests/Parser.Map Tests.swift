import Either
import Parser
import Parser_Map
import Testing

@Suite
struct `Parser.Map Tests` {

    @Test
    func `nonthrowing stages remain exactly nonthrowing`() {
        let parser = Succeed().map { $0 + 1 }
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `fallible upstream with nonthrowing transform preserves upstream failure`() {
        let parser = Fail().map { $0 + 1 }
        requireFailure(parser, UpstreamFailure.self)

        var input = 0
        #expect(throws: UpstreamFailure.failed) {
            try parser.parse(&input)
        }
    }

    @Test
    func `nonthrowing upstream with throwing transform exposes only transform failure`() {
        let parser = Succeed().map {
            (_: consuming Int) throws(TransformFailure) -> Int in
            throw .failed
        }
        requireFailure(parser, TransformFailure.self)

        var input = 0
        #expect(throws: TransformFailure.failed) {
            try parser.parse(&input)
        }
    }

    @Test
    func `two fallible stages use Either`() {
        let upstream = Fail().map {
            (value: consuming Int) throws(TransformFailure) -> Int in
            value + 1
        }
        requireFailure(
            upstream,
            Either<UpstreamFailure, TransformFailure>.self
        )

        var upstreamInput = 0
        #expect {
            try upstream.parse(&upstreamInput)
        } throws: { error in
            guard
                let failure = error
                    as? Either<UpstreamFailure, TransformFailure>
            else { return false }
            return failure.left == .failed
        }

        let transform = FallibleSucceed().map {
            (_: consuming Int) throws(TransformFailure) -> Int in
            throw .failed
        }
        requireFailure(
            transform,
            Either<UpstreamFailure, TransformFailure>.self
        )
        var transformInput = 0
        #expect {
            try transform.parse(&transformInput)
        } throws: { error in
            guard
                let failure = error
                    as? Either<UpstreamFailure, TransformFailure>
            else { return false }
            return failure.right == .failed
        }
    }

    @Test
    func `throws Never transform remains exactly nonthrowing`() {
        func increment(_ value: consuming Int) throws(Never) -> Int {
            value + 1
        }

        let parser = Succeed().map(increment)
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `fallible upstream with throws Never transform preserves upstream failure`() {
        func increment(_ value: consuming Int) throws(Never) -> Int {
            value + 1
        }

        let parser = Fail().map(increment)
        requireFailure(parser, UpstreamFailure.self)
    }

    @Test
    func `constructing a parser with a throwing transform is nonthrowing`() {
        _ = Succeed().map {
            (value: consuming Int) throws(TransformFailure) -> Int in
            value + 1
        }
    }

    @Test
    func `Map consumes noncopyable nonescapable output`() {
        let parser = Linear().map { token in token.value + 1 }
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `Map produces noncopyable output`() {
        let parser = Succeed().map { LinearResult(value: $0 + 1) }
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output.value == 42)
    }
}

private func requireFailure<
    P: Parser.`Protocol` & ~Copyable,
    Failure: Swift.Error
>(
    _ parser: borrowing P,
    _: Failure.Type
) where P.Failure == Failure {}

private enum UpstreamFailure: Swift.Error, Equatable {
    case failed
}

private enum TransformFailure: Swift.Error, Equatable {
    case failed
}

private struct Succeed: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never
    typealias Body = Never

    borrowing func parse(_ input: inout Int) -> Int {
        input
    }
}

private struct Fail: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure
    typealias Body = Never

    borrowing func parse(
        _ input: inout Int
    ) throws(UpstreamFailure) -> Int {
        throw .failed
    }
}

private struct FallibleSucceed: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure
    typealias Body = Never

    borrowing func parse(
        _ input: inout Int
    ) throws(UpstreamFailure) -> Int {
        input
    }
}

private struct ScopedToken: ~Copyable, ~Escapable {
    let value: Int
}

private struct LinearResult: ~Copyable {
    let value: Int
}

private struct Linear: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = ScopedToken
    typealias Failure = Never
    typealias Body = Never

    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedToken {
        ScopedToken(value: input)
    }
}

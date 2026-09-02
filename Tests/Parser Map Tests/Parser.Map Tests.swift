import Either
import Parser
import Parser_Map
import Testing

@Suite
struct `Parser.Map Tests` {

    @Test
    func `nonthrowing stages remain exactly nonthrowing`() {
        let parser = Incremented()
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `fallible upstream with nonthrowing transform preserves upstream failure`() {
        let parser = IncrementedFallibleUpstream()
        requireFailure(parser, UpstreamFailure.self)

        var input = 0
        #expect(throws: UpstreamFailure.failed) {
            try parser.parse(&input)
        }
    }

    @Test
    func `nonthrowing upstream with throwing transform exposes only transform failure`() {
        let parser = ThrowingTransform()
        requireFailure(parser, TransformFailure.self)

        var input = 0
        #expect(throws: TransformFailure.failed) {
            try parser.parse(&input)
        }
    }

    @Test
    func `two fallible stages use Either`() {
        let upstream = FallibleUpstreamThrowingTransform()
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

        let transform = FallibleUpstreamFailingTransform()
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
        let parser = IncrementedByNeverThrowingFunction()
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `fallible upstream with throws Never transform preserves upstream failure`() {
        let parser = FallibleUpstreamNeverThrowingFunction()
        requireFailure(parser, UpstreamFailure.self)
    }

    @Test
    func `constructing a parser with a throwing transform is nonthrowing`() {
        _ = ThrowingTransform().body
    }

    @Test
    func `Map consumes noncopyable nonescapable output`() {
        let parser = IncrementedScopedToken()
        requireFailure(parser, Never.self)

        var input = 41
        let output = parser.parse(&input)

        #expect(output == 42)
    }

    @Test
    func `Map produces noncopyable output`() {
        let parser = IncrementedIntoLinearResult()
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
)
where
    P.Input: ~Copyable & ~Escapable,
    P.Output: ~Copyable & ~Escapable,
    P.Failure == Failure
{}

private func increment(_ value: consuming Int) throws(Never) -> Int {
    value + 1
}

private struct Incremented: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    var body: some Parser.`Protocol`<Int, Int, Never> {
        Succeed().map { $0 + 1 }
    }
}

private struct IncrementedFallibleUpstream: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    var body: some Parser.`Protocol`<Int, Int, UpstreamFailure> {
        Fail().map { $0 + 1 }
    }
}

private struct ThrowingTransform: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = TransformFailure

    var body: some Parser.`Protocol`<Int, Int, TransformFailure> {
        Succeed().map {
            (_: consuming Int) throws(TransformFailure) -> Int in
            throw .failed
        }
    }
}

private struct FallibleUpstreamThrowingTransform: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Either<UpstreamFailure, TransformFailure>

    var body: some Parser.`Protocol`<
        Int,
        Int,
        Either<UpstreamFailure, TransformFailure>
    > {
        Fail().map {
            (value: consuming Int) throws(TransformFailure) -> Int in
            value + 1
        }
    }
}

private struct FallibleUpstreamFailingTransform: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Either<UpstreamFailure, TransformFailure>

    var body: some Parser.`Protocol`<
        Int,
        Int,
        Either<UpstreamFailure, TransformFailure>
    > {
        FallibleSucceed().map {
            (_: consuming Int) throws(TransformFailure) -> Int in
            throw .failed
        }
    }
}

private struct IncrementedByNeverThrowingFunction: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    var body: some Parser.`Protocol`<Int, Int, Never> {
        Succeed().map(increment)
    }
}

private struct FallibleUpstreamNeverThrowingFunction: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    var body: some Parser.`Protocol`<Int, Int, UpstreamFailure> {
        Fail().map(increment)
    }
}

private struct IncrementedScopedToken: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    var body: some Parser.`Protocol`<Int, Int, Never> {
        Linear().map { token in token.value + 1 }
    }
}

private struct IncrementedIntoLinearResult: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = LinearResult
    typealias Failure = Never

    var body: some Parser.`Protocol`<Int, LinearResult, Never> {
        Succeed().map { LinearResult(value: $0 + 1) }
    }
}

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

    borrowing func parse(_ input: inout Int) -> Int {
        input
    }
}

private struct Fail: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

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

    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedToken {
        ScopedToken(value: input)
    }
}

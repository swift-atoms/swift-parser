import Either
import Parser
import Parser_Error
import Parser_Map
import Testing

@Suite
struct `Parser.Error` {

    @Test
    func `error map rewrites the upstream failure`() {
        let parser = Remapped()
        requireFailure(parser, DownstreamFailure.self)

        var input = 0
        #expect(throws: DownstreamFailure.upstream) {
            try parser.parse(&input)
        }
    }

    @Test
    func `error map leaves a successful output untouched`() throws(any Swift.Error) {
        let parser = RemappedSuccess()
        requireFailure(parser, DownstreamFailure.self)

        var input = 41
        let output = try parser.parse(&input)

        #expect(output == 41)
    }

    @Test
    func `error map flattens an Either produced by map`() {
        let parser = Flattened()
        requireFailure(parser, DownstreamFailure.self)

        var input = 0
        #expect(throws: DownstreamFailure.upstream) {
            try parser.parse(&input)
        }
    }

    @Test
    func `error map reaches the transform side of an Either`() {
        let parser = FlattenedTransform()
        requireFailure(parser, DownstreamFailure.self)

        var input = 0
        #expect(throws: DownstreamFailure.transform) {
            try parser.parse(&input)
        }
    }

}

private func requireFailure<
    P: Parser.`Protocol`,
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

private struct Remapped: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = DownstreamFailure

    var body: some Parser.`Protocol`<Int, Int, DownstreamFailure> {
        Fail().error.map { (_: UpstreamFailure) -> DownstreamFailure in .upstream }
    }
}

private struct RemappedSuccess: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = DownstreamFailure

    var body: some Parser.`Protocol`<Int, Int, DownstreamFailure> {
        FallibleSucceed().error.map { (_: UpstreamFailure) -> DownstreamFailure in .upstream }
    }
}

private struct Flattened: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = DownstreamFailure

    var body: some Parser.`Protocol`<Int, Int, DownstreamFailure> {
        Fail()
            .map { (value: consuming Int) throws(TransformFailure) -> Int in value + 1 }
            .error
            .map { (failure: Either<UpstreamFailure, TransformFailure>) -> DownstreamFailure in
                switch failure {
                case .left: return .upstream
                case .right: return .transform
                }
            }
    }
}

private struct FlattenedTransform: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = DownstreamFailure

    var body: some Parser.`Protocol`<Int, Int, DownstreamFailure> {
        FallibleSucceed()
            .map { (_: consuming Int) throws(TransformFailure) -> Int in throw .failed }
            .error
            .map { (failure: Either<UpstreamFailure, TransformFailure>) -> DownstreamFailure in
                switch failure {
                case .left: return .upstream
                case .right: return .transform
                }
            }
    }
}

private enum UpstreamFailure: Swift.Error, Equatable {
    case failed
}

private enum TransformFailure: Swift.Error, Equatable {
    case failed
}

private enum DownstreamFailure: Swift.Error, Equatable {
    case upstream
    case transform
}

private struct Fail: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    borrowing func parse(_ input: inout Int) throws(UpstreamFailure) -> Int {
        throw .failed
    }
}

private struct FallibleSucceed: Parser.`Protocol` {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = UpstreamFailure

    borrowing func parse(_ input: inout Int) throws(UpstreamFailure) -> Int {
        input
    }
}

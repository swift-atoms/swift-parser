import Either
import Parser
import Parser_FlatMap
import Testing

@Suite
struct `Parser.FlatMap` {

    @Test
    func `the downstream parser depends on the upstream output`() throws(any Swift.Error) {
        var input: Substring = "2ab!"
        let output = try Counted().parse(&input)
        #expect(output == "ab")
        #expect(input == "!")
    }

    @Test
    func `an upstream failure is the left branch`() {
        var input: Substring = ""
        #expect(throws: Either<DigitError, TakeError>.left(.empty)) {
            try Counted().parse(&input)
        }
    }

    @Test
    func `a downstream failure is the right branch`() {
        var input: Substring = "3a"
        #expect(throws: Either<DigitError, TakeError>.right(.short)) {
            try Counted().parse(&input)
        }
    }
}

private struct Counted: Parser.`Protocol` {
    typealias Failure = Either<DigitError, TakeError>

    var body: some Parser.`Protocol`<Substring, Substring, Either<DigitError, TakeError>> {
        Digit().flatMap { count in Take(count) }
    }
}

private enum DigitError: Swift.Error, Equatable {
    case empty
}

private enum TakeError: Swift.Error, Equatable {
    case short
}

private struct Digit: Parser.`Protocol` {
    borrowing func parse(_ input: inout Substring) throws(DigitError) -> Int {
        guard let first = input.first, let value = first.wholeNumberValue else { throw .empty }
        input = input.dropFirst()
        return value
    }
}

private struct Take: Parser.`Protocol` {
    let count: Int

    init(_ count: Int) {
        self.count = count
    }

    borrowing func parse(_ input: inout Substring) throws(TakeError) -> Substring {
        guard input.count >= count else { throw .short }
        let output = input.prefix(count)
        input = input.dropFirst(count)
        return output
    }
}

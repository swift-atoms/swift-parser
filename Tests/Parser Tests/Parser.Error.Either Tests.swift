import Either
import Parser
import Testing

@Suite
struct `Parser.Error.Either Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Error.Either Tests`.Unit {
    typealias E = Either<Parser.EndOfInput.Error, Parser.Match.Error>

    @Test
    func `left case extracts left value`() {
        let error = E.left(.unexpected(expected: "byte"))

        #expect(error.left != nil)
        #expect(error.right == nil)
    }

    @Test
    func `right case extracts right value`() {
        let error = E.right(.expectedEnd(remaining: 5))

        #expect(error.left == nil)
        #expect(error.right != nil)
    }

    @Test
    func `first accessor is alias for left`() {
        let error = E.left(.unexpected(expected: "test"))

        #expect(error.first != nil)
    }

    @Test
    func `case payload access distinguishes values`() {
        let a = E.left(.unexpected(expected: "x"))
        let b = E.left(.unexpected(expected: "x"))
        let c = E.right(.expectedEnd(remaining: 1))

        #expect(a.left == b.left)
        #expect(a.right == nil)
        #expect(c.left == nil)
        #expect(c.right != nil)
    }
}

extension `Parser.Error.Either Tests`.`Edge Case` {
    @Test
    func `left Never extracts right unconditionally`() {
        let error: Either<Never, Parser.Match.Error> =
            .right(.expectedEnd(remaining: 3))

        let extracted = error.value

        #expect(extracted == .expectedEnd(remaining: 3))
    }

    @Test
    func `right Never extracts left unconditionally`() {
        let error: Either<Parser.Match.Error, Never> =
            .left(.predicateFailed(description: "test"))

        let extracted = error.value

        #expect(extracted == .predicateFailed(description: "test"))
    }
}

import Either
import Parser
import Parser_Filter
import Predicate
import Testing

@Suite
struct `Parser.Filter` {

    @Test
    func `passes output satisfying its predicate`() throws(any Swift.Error) {
        var input: Void = ()
        let parser = ClosureFiltered()

        let output = try parser.parse(&input)

        #expect(output == 3)
    }

    @Test
    func `accepts a domain Predicate`() throws(any Swift.Error) {
        var input: Void = ()
        let parser = PredicateFiltered()

        let output = try parser.parse(&input)

        #expect(output == 3)
    }

    @Test
    func `composes Predicate algebra at the filter site`() {
        var input: Void = ()
        let parser = AlgebraFiltered()

        do {
            _ = try parser.parse(&input)
            Issue.record("Expected the composed predicate to fail")
        } catch {
            switch error {
            case .left:
                Issue.record("A Never upstream failure is unreachable")
            case .right(.validationFailed(let value, _)):
                #expect(value == "3")
            }
        }
    }

    @Test
    func `owns predicate validation failure`() {
        var input: Void = ()
        let parser = RejectingClosureFiltered()

        do {
            _ = try parser.parse(&input)
            Issue.record("Expected the filter predicate to fail")
        } catch {
            switch error {
            case .left:
                Issue.record("A Never upstream failure is unreachable")
            case .right(.validationFailed(let value, let reason)):
                #expect(value == "-1")
                #expect(reason == "filter predicate")
            }
        }
    }
}

private typealias Validation = Either<Never, Parser.Filter<Value>.Error>

private struct ClosureFiltered: Parser.`Protocol` {
    typealias Input = Void
    typealias Output = Int
    typealias Failure = Validation

    var body: some Parser.`Protocol`<Void, Int, Validation> {
        Value(3).filter { $0 > 0 }
    }
}

private struct PredicateFiltered: Parser.`Protocol` {
    typealias Input = Void
    typealias Output = Int
    typealias Failure = Validation

    var body: some Parser.`Protocol`<Void, Int, Validation> {
        Value(3).filter(.greater.than(0))
    }
}

private struct AlgebraFiltered: Parser.`Protocol` {
    typealias Input = Void
    typealias Output = Int
    typealias Failure = Validation

    var body: some Parser.`Protocol`<Void, Int, Validation> {
        let positive = Predicate<Int> { $0 > 0 }
        let even = Predicate<Int> { $0.isMultiple(of: 2) }
        Value(3).filter(positive && even)
    }
}

private struct RejectingClosureFiltered: Parser.`Protocol` {
    typealias Input = Void
    typealias Output = Int
    typealias Failure = Validation

    var body: some Parser.`Protocol`<Void, Int, Validation> {
        Value(-1).filter { $0 > 0 }
    }
}

private struct Value: Parser.`Protocol` {
    typealias Input = Void
    typealias Output = Int
    typealias Failure = Never
    typealias Body = Never

    let value: Int

    init(_ value: Int) {
        self.value = value
    }

    borrowing func parse(_ input: inout Void) -> Int {
        value
    }
}

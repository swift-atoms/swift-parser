import Either
import Parser
import Parser_Filter
import Testing

@Suite
struct `Parser.Filter` {

    @Test
    func `passes output satisfying its predicate`() throws(any Swift.Error) {
        var input: Void = ()
        let parser = Value(3).filter { $0 > 0 }

        let output = try parser.parse(&input)

        #expect(output == 3)
    }

    @Test
    func `owns predicate validation failure`() {
        var input: Void = ()
        let parser = Value(-1).filter { $0 > 0 }

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

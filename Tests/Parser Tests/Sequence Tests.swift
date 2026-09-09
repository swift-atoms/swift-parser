import Parser
import Testing

@Suite
struct `Sequence groups bodies independently of their interpretation` {

    @Test
    func `a group can hold a scoped body`() {
        let values = [1, 2]
        let sequence = Parser::Sequence(values.span)
        #expect(sequence.body[0] == 1)
        #expect(sequence.body[1] == 2)
    }

    @Test
    func `a grouped linear parser transfers into its adapter`() {
        let sequence = Parser::Sequence(Linear())
        let parser = sequence.parser()
        var input = 0
        #expect(parser.parse(&input) == 1)
        #expect(parser.parse(&input) == 2)
    }

    private struct Linear: Parsing, ~Copyable {
        borrowing func parse(_ input: inout Int) -> Int {
            input += 1
            return input
        }
    }
}

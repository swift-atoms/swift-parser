import Parser
import Parser_Witness
import Testing

@Suite
struct `Parser.Witness` {

    @Test
    func `a witness parses through its closure`() throws(any Swift.Error) {
        let witness = Parser.Witness<Substring, Character, WitnessError> { input throws(WitnessError) in
            guard let first = input.first else { throw .empty }
            input = input.dropFirst()
            return first
        }
        var input: Substring = "ab"
        #expect(try witness.parse(&input) == "a")
        #expect(input == "b")
    }

    @Test
    func `a pure witness needs no try`() {
        let pure = Parser.Pure<Substring, Int> { input in input.count }
        var input: Substring = "abc"
        #expect(pure.parse(&input) == 3)
    }

    @Test
    func `a witness propagates its typed failure`() {
        let witness = Parser.Witness<Substring, Character, WitnessError> { _ throws(WitnessError) in
            throw .empty
        }
        var input: Substring = ""
        #expect(throws: WitnessError.empty) {
            try witness.parse(&input)
        }
    }
}

private enum WitnessError: Swift.Error, Equatable {
    case empty
}

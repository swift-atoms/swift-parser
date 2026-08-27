import Parser
import Testing

@Suite
struct `Parser.Map.Transform` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Map.Transform`.Unit {
    @Test
    func `transforms output of upstream parser`() throws(any Swift.Error) {
        let parser = Parser.First.Element<Parser.Test.Input>()
            .map { Int($0) }
        var input = Parser.Test.Input([0x0A])

        let result = try parser.parse(&input)

        #expect(result == 10)
    }

    @Test
    func `preserves input consumption from upstream`() throws(any Swift.Error) {
        let parser = Parser.First.Element<Parser.Test.Input>()
            .map { String($0, radix: 16) }
        var input = Parser.Test.Input([0xFF, 0x01])

        _ = try parser.parse(&input)

        #expect(input.first == 0x01)
    }
}

extension `Parser.Map.Transform`.`Edge Case` {
    @Test
    func `upstream failure propagates through map`() {
        let parser = Parser.First.Element<Parser.Test.Input>()
            .map { $0 * 2 }
        var input = Parser.Test.Input([])

        #expect(throws: Parser.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }
}

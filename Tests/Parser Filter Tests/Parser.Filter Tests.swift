import Parser_Test_Support
import Testing

@Suite
struct `Parser.Filter` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Filter`.Unit {
    @Test
    func `passes when predicate returns true`() throws(any Swift.Error) {
        let parser = Parser.First.Element<Parser.Test.Input>()
            .filter { $0 > 0x00 }
        var input = Parser.Test.Input([0x42])

        let result = try parser.parse(&input)

        #expect(result == 0x42)
    }
}

extension `Parser.Filter`.`Edge Case` {
    @Test
    func `fails when predicate returns false`() {
        let parser = Parser.First.Element<Parser.Test.Input>()
            .filter { $0 == 0x00 }
        var input = Parser.Test.Input([0xFF])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `upstream failure propagates through filter`() {
        let parser = Parser.First.Element<Parser.Test.Input>()
            .filter { _ in true }
        var input = Parser.Test.Input([])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }
}

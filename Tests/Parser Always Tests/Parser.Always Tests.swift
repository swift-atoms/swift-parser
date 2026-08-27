import Parser
import Parser_Test_Support
import Testing

@Suite
struct `Parser.Always` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Always`.Unit {
    @Test
    func `returns provided value without consuming input`() {
        let parser = Parser.Always<Parser.Test.Input, Int>(42)
        var input = Parser.Test.Input([0x01, 0x02, 0x03])

        let result = parser.parse(&input)

        #expect(result == 42)
        #expect(!input.isEmpty)
    }

    @Test
    func `produces Void output`() {
        let parser = Parser.Always<Parser.Test.Input, Void>(())
        var input = Parser.Test.Input([0xFF])

        parser.parse(&input)

        #expect(!input.isEmpty)
    }
}

extension `Parser.Always`.`Edge Case` {
    @Test
    func `succeeds on empty input`() {
        let parser = Parser.Always<Parser.Test.Input, String>("hello")
        var input = Parser.Test.Input([])

        let result = parser.parse(&input)

        #expect(result == "hello")
        #expect(input.isEmpty)
    }
}

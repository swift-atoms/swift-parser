import Parser
import Parser_Always
import Testing

@Suite
struct `Parser.Always` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Always`.Unit {
    @Test
    func `returns provided value without consuming input`() {
        let parser = Parser.Always<[UInt8], Int>(42)
        var input: [UInt8] = [0x01, 0x02, 0x03]

        let result = parser.parse(&input)

        #expect(result == 42)
        #expect(!input.isEmpty)
    }

    @Test
    func `produces Void output`() {
        let parser = Parser.Always<[UInt8], Void>(())
        var input: [UInt8] = [0xFF]

        parser.parse(&input)

        #expect(!input.isEmpty)
    }
}

extension `Parser.Always`.`Edge Case` {
    @Test
    func `succeeds on empty input`() {
        let parser = Parser.Always<[UInt8], String>("hello")
        var input: [UInt8] = []

        let result = parser.parse(&input)

        #expect(result == "hello")
        #expect(input.isEmpty)
    }
}

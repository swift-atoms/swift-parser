#if Always
import Always
import Parser
import Testing

@Suite
struct `Always.Parser` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Always.Parser`.Unit {
    @Test
    func `returns provided value without consuming input`() {
        let parser = Always<Int>.Parser<[UInt8]>(42)
        var input: [UInt8] = [0x01, 0x02, 0x03]

        let result = parser.parse(&input)

        #expect(result == 42)
        #expect(!input.isEmpty)
    }

    @Test
    func `produces Void output`() {
        let parser = Always<Void>.Parser<[UInt8]>(())
        var input: [UInt8] = [0xFF]

        parser.parse(&input)

        #expect(!input.isEmpty)
    }

    @Test
    func `lifts an Always through parser()`() {
        let parser: Always<Int>.Parser<[UInt8]> = Always(7).parser()
        var input: [UInt8] = []

        #expect(parser.parse(&input) == 7)
    }
}

extension `Always.Parser`.`Edge Case` {
    @Test
    func `succeeds on empty input`() {
        let parser = Always<String>.Parser<[UInt8]>("hello")
        var input: [UInt8] = []

        let result = parser.parse(&input)

        #expect(result == "hello")
        #expect(input.isEmpty)
    }
}

#endif

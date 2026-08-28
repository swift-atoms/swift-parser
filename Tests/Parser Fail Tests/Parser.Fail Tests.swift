import Parser_Fail
import Parser_Match
import Testing

@Suite
struct `Parser.Fail` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Fail`.Unit {
    @Test
    func `always throws the provided error`() {
        let parser = Parser.Fail<[UInt8], Int, Parser.Match.Error>(
            .predicateFailed(description: "test error")
        )
        var input: [UInt8] = [0x01, 0x02]

        #expect(throws: Parser.Match.Error.self) {
            try parser.parse(&input)
        }
    }
}

extension `Parser.Fail`.`Edge Case` {
    @Test
    func `throws on empty input without consuming`() {
        let parser = Parser.Fail<[UInt8], Void, TestError>(
            .expectedInput
        )
        var input: [UInt8] = []

        #expect(throws: TestError.self) {
            try parser.parse(&input)
        }
    }
}

private enum TestError: Error {
    case expectedInput
}

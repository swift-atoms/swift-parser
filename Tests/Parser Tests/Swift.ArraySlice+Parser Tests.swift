import Parser
import Testing

@Suite
struct `Swift.ArraySlice+Parser Tests` {
    @Test
    func `a literal consumes exactly its matching prefix`() throws {
        var input: ArraySlice<Int> = [1, 2, 3]
        try Parser { [0, 1, 2][1...] }.parse(&input)
        #expect(input == [3])
    }

    @Test
    func `a mismatch leaves input unchanged`() {
        var input: ArraySlice<Int> = [1, 9, 3]
        #expect(throws: Swift.ArraySlice<Int>.Parser<ArraySlice<Int>>.Error.mismatch) {
            try Parser { [0, 1, 2][1...] }.parse(&input)
        }
        #expect(input == [1, 9, 3])
    }

    @Test
    func `explicit parser types accept a literal`() throws {
        let parser = Parser<ArraySlice<Int>, Void, Swift.ArraySlice<Int>.Parser<ArraySlice<Int>>.Error> {
            [0, 1, 2][1...]
        }
        var input: ArraySlice<Int> = [1, 2, 3]
        try parser.parse(&input)
        #expect(input == [3])
    }

    @Test
    func `an empty literal consumes nothing`() throws {
        var input: ArraySlice<Int> = [1, 2, 3]
        try Parser { [Int]()[...] }.parse(&input)
        #expect(input == [1, 2, 3])
    }

    @Test
    func `a short input is not partially consumed`() {
        var input: ArraySlice<Int> = [1]
        #expect(throws: Swift.ArraySlice<Int>.Parser<ArraySlice<Int>>.Error.mismatch) {
            try Parser { [0, 1, 2][1...] }.parse(&input)
        }
        #expect(input == [1])
    }
}

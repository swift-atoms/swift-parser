#if Prefix && Iterator && Collection
import Prefix_Parser_Test_Support
import Prefix
import Prefix_Collection
import Parser
import Collection
import Iterator
import Testing

@Suite struct PrefixCollectionParserTests {
    @Test func boundedSelectionConsumesExactlyItsOutput() throws {
        var input = Fixture.Input(utf8: "abcd")
        let output = try Prefix(minimum: 2, maximum: 2).parser(forCollection: Fixture.Input.self).parse(&input)
        #expect(output == Fixture.Input(utf8: "ab"))
        #expect(input == Fixture.Input(utf8: "cd"))
    }
    @Test func delimiterFailureLeavesInputUnchanged() {
        var input = Fixture.Input(utf8: "ab-")
        do {
            _ = try Prefix.UpTo(Array("--".utf8)).parser(forCollection: Fixture.Input.self).parse(&input)
            Issue.record("Expected missing delimiter")
        } catch { #expect(error == .delimiterNotFound) }
        #expect(input == Fixture.Input(utf8: "ab-"))
    }
    @Test func whileAndThroughCompose() throws {
        var input = Fixture.Input(utf8: "aa--z")
        let first = try Prefix.While<UInt8> { $0 == 97 }.parser(forCollection: Fixture.Input.self).parse(&input)
        #expect(first == Fixture.Input(utf8: "aa"))
        let delimiter = try Prefix.Through(Array("--".utf8)).parser(forCollection: Fixture.Input.self).parse(&input)
        #expect(delimiter == Fixture.Input(utf8: "--"))
        #expect(input == Fixture.Input(utf8: "z"))
    }
}

private struct Owned: Collection.`Protocol`, ~Copyable {
    var wrapped: Fixture.Input
    var startIndex: Fixture.Input.Index { wrapped.startIndex }
    var endIndex: Fixture.Input.Index { wrapped.endIndex }
    subscript(_ index: Fixture.Input.Index) -> UInt8 { wrapped[index] }
    func index(after index: Fixture.Input.Index) -> Fixture.Input.Index { wrapped.index(after: index) }
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator::Iterator.Chunk<UInt8> { wrapped.makeIterator() }
}
extension PrefixCollectionParserTests {
    @Test func selectionBorrowsANoncopyableCollection() throws {
        let source = Owned(wrapped: Fixture.Input(utf8: "aa--"))
        let countEnd = try Prefix(minimum: 2, maximum: 2).end(inCollection: source)
        let predicateEnd = try Prefix.While<UInt8> { $0 == 97 }.end(inCollection: source)
        let delimiterEnd = try Prefix.UpTo(Array("--".utf8)).end(inCollection: source)
        #expect(countEnd == predicateEnd)
        #expect(countEnd == delimiterEnd)
        #expect(source.startIndex != source.endIndex)
    }
}

extension PrefixCollectionParserTests {
    @Test(arguments: [0, 1, 3])
    func exactCountIncludesEmptyAndCompleteInput(_ count: Int) throws {
        let original = Fixture.Input([1, 2, 3])
        var input = original
        let output = try Prefix(minimum: count, maximum: count).parser(forCollection: Fixture.Input.self).parse(&input)
        #expect(output == Fixture.Input(Array([1, 2, 3].prefix(count))))
        #expect(input == Fixture.Input(Array([1, 2, 3].dropFirst(count))))
        var empty = Fixture.Input([])
        #expect(try Prefix(maximum: 0).parser(forCollection: Fixture.Input.self).parse(&empty) == Fixture.Input([]))
    }
    @Test func insufficientCountDoesNotConsumeInput() {
        var input = Fixture.Input([1, 2])
        do {
            _ = try Prefix(minimum: 3, maximum: 3).parser(forCollection: Fixture.Input.self).parse(&input)
            Issue.record("Expected insufficient input")
        } catch { #expect(error == .insufficientElements(minimum: 3, actual: 2)) }
        #expect(input == Fixture.Input([1, 2]))
    }
}

#endif

#if Search && Repetition && Iterator && Collection
import Parser_Test_Support
import Search
import Repetition
import Cardinal
import Predicate
import Parser
import Collection
import Iterator
import Testing

@Suite struct CollectionSelectionParserTests {
    @Test func boundedSelectionConsumesExactlyItsOutput() throws {
        var input = Fixture.Input(utf8: "abcd")
        let output = try (Cardinal(UInt(2))...Cardinal(UInt(2))).parser(forCollection: Fixture.Input.self).parse(&input)
        #expect(output == Fixture.Input(utf8: "ab"))
        #expect(input == Fixture.Input(utf8: "cd"))
    }
    @Test func delimiterFailureLeavesInputUnchanged() {
        var input = Fixture.Input(utf8: "ab-")
        do {
            _ = try Search(Array("--".utf8)).selecting(.start).parser(forCollection: Fixture.Input.self).parse(&input)
            Issue.record("Expected missing delimiter")
        } catch { #expect(error == .notFound) }
        #expect(input == Fixture.Input(utf8: "ab-"))
    }
    @Test func whileAndThroughCompose() throws {
        var input = Fixture.Input(utf8: "aa--z")
        let first = try Repetition((Cardinal.zero...), operation: Predicate<UInt8>{ $0 == 97 }).parser(forCollection: Fixture.Input.self).parse(&input)
        #expect(first == Fixture.Input(utf8: "aa"))
        let delimiter = try Search(Array("--".utf8)).selecting(.end).parser(forCollection: Fixture.Input.self).parse(&input)
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
extension CollectionSelectionParserTests {
    @Test func selectionBorrowsANoncopyableCollection() throws {
        let source = Owned(wrapped: Fixture.Input(utf8: "aa--"))
        let countEnd = try (Cardinal(UInt(2))...Cardinal(UInt(2))).end(inCollection: source)
        let predicateEnd = try Repetition((Cardinal.zero...), operation: Predicate<UInt8>{ $0 == 97 }).end(inCollection: source)
        let delimiterEnd = try Search(Array("--".utf8)).selecting(.start).end(inCollection: source)
        #expect(countEnd == predicateEnd)
        #expect(countEnd == delimiterEnd)
        #expect(source.startIndex != source.endIndex)
    }
}

extension CollectionSelectionParserTests {
    @Test(arguments: [0, 1, 3])
    func exactCountIncludesEmptyAndCompleteInput(_ count: Int) throws {
        let original = Fixture.Input([1, 2, 3])
        var input = original
        let output = try (Cardinal(UInt(count))...Cardinal(UInt(count))).parser(forCollection: Fixture.Input.self).parse(&input)
        #expect(output == Fixture.Input(Array([1, 2, 3].prefix(count))))
        #expect(input == Fixture.Input(Array([1, 2, 3].dropFirst(count))))
        var empty = Fixture.Input([])
        #expect(try (Cardinal.zero...Cardinal(UInt(0))).parser(forCollection: Fixture.Input.self).parse(&empty) == Fixture.Input([]))
    }
    @Test func insufficientCountDoesNotConsumeInput() {
        var input = Fixture.Input([1, 2])
        do {
            _ = try (Cardinal(UInt(3))...Cardinal(UInt(3))).parser(forCollection: Fixture.Input.self).parse(&input)
            Issue.record("Expected insufficient input")
        } catch { #expect(error == .insufficient(actual: 2)) }
        #expect(input == Fixture.Input([1, 2]))
    }
}

#endif

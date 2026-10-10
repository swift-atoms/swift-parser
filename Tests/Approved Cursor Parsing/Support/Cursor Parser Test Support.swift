#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
public import Cursor
public import Parser



    public enum CursorParserTest {}


extension CursorParserTest {

    public struct Take: Sendable {

        public let count: Int

        @inlinable
        public init(_ count: Int) {
            self.count = count
        }
    }
}

extension CursorParserTest.Take {

    public enum Error: Swift.Error, Sendable, Equatable {

        case countTooLow(expected: Int, got: Int)
    }
}

extension CursorParserTest.Take: Parsing {


    public typealias Input = ArraySlice<UInt8>

    public typealias Output = [UInt8]

    public typealias Failure = CursorParserTest.Take.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> [UInt8] {
        var result: [UInt8] = []
        result.reserveCapacity(count)
        while result.count < count {
            guard let element = input.next() else {
                throw .countTooLow(expected: count, got: result.count)
            }
            result.append(element)
        }
        return result
    }
}

extension CursorParserTest {

    public struct TakeWhile {

        @usableFromInline
        let predicate: (UInt8) -> Bool

        @inlinable
        public init(_ predicate: @escaping (UInt8) -> Bool) {
            self.predicate = predicate
        }
    }
}

extension CursorParserTest.TakeWhile: Parsing {


    public typealias Input = ArraySlice<UInt8>

    public typealias Output = [UInt8]

    public typealias Failure = Never

    @inlinable
    public func parse(_ input: inout Input) -> [UInt8] {
        var result: [UInt8] = []
        while let element = input.first, predicate(element) {
            _ = input.popFirst()
            result.append(element)
        }
        return result
    }
}

extension CursorParserTest {

    public struct Rest: Sendable {

        @inlinable
        public init() {}
    }
}

extension CursorParserTest.Rest: Parsing {


    public typealias Input = ArraySlice<UInt8>

    public typealias Output = [UInt8]

    public typealias Failure = Never

    @inlinable
    public func parse(_ input: inout Input) -> [UInt8] {
        var result: [UInt8] = []
        while let element = input.next() {
            result.append(element)
        }
        return result
    }
}

extension CursorParserTest {

    public struct End: Sendable {

        @inlinable
        public init() {}
    }
}

extension CursorParserTest.End {

    public enum Error: Swift.Error, Sendable, Equatable {

        case unexpectedInput
    }
}

extension CursorParserTest.End: Parsing {


    public typealias Input = ArraySlice<UInt8>

    public typealias Output = Void

    public typealias Failure = CursorParserTest.End.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        guard input.isEmpty else {
            throw .unexpectedInput
        }
    }
}
#endif

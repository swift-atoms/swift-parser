public import Index_Primitives

extension Parser {

    public struct Spanned<T> {

        public let value: T

        public let start: Int

        public let end: Int

        @inlinable
        public init(_ value: T, start: Int, end: Int) {
            self.value = value
            self.start = start
            self.end = end
        }
    }
}

extension Parser.Spanned {

    @inlinable
    public var length: Int {
        end - start
    }

    @inlinable
    public var range: Range<Int> {
        start..<end
    }
}

extension Parser.Spanned: Sendable where T: Sendable {}

extension Parser.Spanned {

    @inlinable
    public init<Element: ~Copyable & ~Escapable>(
        _ value: T,
        start: Index<Element>,
        end: Index<Element>
    ) {
        self.init(value, start: Int(bitPattern: start), end: Int(bitPattern: end))
    }
}

extension Parser.Spanned: Equatable where T: Equatable {}

extension Parser.Spanned: Hashable where T: Hashable {}

extension Parser.Spanned {

    @inlinable
    public func map<U>(_ transform: (T) -> U) -> Parser.Spanned<U> {
        Parser.Spanned<U>(transform(value), start: start, end: end)
    }
}

extension Parser.Spanned: CustomStringConvertible where T: CustomStringConvertible {

    public var description: String {
        "\(value) [\(start)..<\(end)]"
    }
}

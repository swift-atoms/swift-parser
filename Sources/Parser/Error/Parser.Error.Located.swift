extension Parser {

    public typealias Position = Int
}

extension Parser.Error {

    public struct Located<E: Swift.Error>: Swift.Error, Sendable {

        public let error: E

        public let offset: Parser.Position

        @inlinable
        public init(_ error: E, at offset: Parser.Position) {
            self.error = error
            self.offset = offset
        }
    }
}

extension Parser.Error.Located: Equatable where E: Equatable {}

extension Parser.Error.Located: Hashable where E: Hashable {}

extension Parser.Error.Located: CustomStringConvertible {

    public var description: String {
        "at offset \(offset): \(error)"
    }
}

extension Parser.Error.Located {

    @inlinable
    public func map<NewE: Swift.Error>(
        _ transform: (E) -> NewE
    ) -> Parser.Error.Located<NewE> {
        Parser.Error.Located<NewE>(transform(error), at: offset)
    }
}

extension Parser {

    @available(*, deprecated, renamed: "Error.Located")
    public typealias Located<E: Swift.Error> = Parser.Error.Located<E>
}

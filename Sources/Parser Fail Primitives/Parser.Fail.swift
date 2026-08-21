extension Parser {

    public struct Fail<Input, Output, F: Swift.Error>: Sendable {
        @usableFromInline
        let error: F

        @inlinable
        public init(_ error: F) {
            self.error = error
        }
    }
}

extension Parser.Fail: Parser.`Protocol` {

    public typealias Failure = F

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        throw error
    }
}

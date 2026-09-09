#if Predicate
public import Predicate

extension Predicate where T: Copyable & Escapable {
    /// Consumes exactly one element satisfying the predicate, not a maximal prefix.
    public struct Parser<Input: Swift.Collection>: Parser::Parsing
    where Input.SubSequence == Input, Input.Element == T {
        public typealias Output = T
        public typealias Failure = Error
        public typealias Error = Predicate<T>.Error
        public let wrapped: Predicate<T>
        public init(_ wrapped: Predicate<T>) { self.wrapped = wrapped }

        public borrowing func parse(_ input: inout Input) throws(Error) -> T {
            guard let element = input.first else { throw .empty }
            guard wrapped(element) else { throw .rejected }
            input = input[input.index(after: input.startIndex)...]
            return element
        }
    }
}

extension Parser::Builder
where Input: Swift.Collection, Input.SubSequence == Input {
    public static func buildExpression(_ predicate: Predicate<Input.Element>) -> Predicate<Input.Element>.Parser<Input> {
        .init(predicate)
    }
}

#endif

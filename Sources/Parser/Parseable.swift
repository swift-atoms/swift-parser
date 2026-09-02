public protocol Parseable {

    associatedtype Parser: Parsing
    where
        Parser.Input: ~Copyable & ~Escapable,
        Parser.Output: ~Copyable & ~Escapable

    static var parser: Parser { get }
}

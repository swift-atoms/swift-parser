public protocol Parseable {

    associatedtype Parser: Parser::Parser.`Protocol`
    where
        Parser.Input: ~Copyable & ~Escapable,
        Parser.Output: ~Copyable & ~Escapable

    static var parser: Parser { get }
}

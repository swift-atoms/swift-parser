public protocol Parseable {

    associatedtype Parser: Parser::Parser.`Protocol`

    static var parser: Parser { get }
}

public protocol Parseable {

    associatedtype Parser: __Parser.`Protocol`

    static var parser: Parser { get }
}

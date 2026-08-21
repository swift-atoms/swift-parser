public protocol Parseable {

    associatedtype Parser: Parser_Primitive.Parser.`Protocol`

    static var parser: Parser { get }
}

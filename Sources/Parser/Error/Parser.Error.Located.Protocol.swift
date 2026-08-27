public import Text

public protocol __ParserErrorLocatedProtocol: Swift.Error {

    var offset: Text.Position { get }
}

extension Parser.Error.Located {

    public typealias `Protocol` = __ParserErrorLocatedProtocol
}

extension Parser.Error.Located: __ParserErrorLocatedProtocol {}

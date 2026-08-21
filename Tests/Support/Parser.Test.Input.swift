public import Input_Primitives
public import Parser_Primitives

extension Parser.Test {

    public typealias Input = Input_Primitives.Input.Slice<Parser.Test.Bytes>
}

extension Input.Slice: @retroactive ExpressibleByArrayLiteral
where Base == Parser.Test.Bytes {
    public init(arrayLiteral elements: UInt8...) {
        self.init(Parser.Test.Bytes(elements))
    }
}

extension Input.Slice where Base == Parser.Test.Bytes {

    public init(_ bytes: [UInt8]) {
        self.init(Parser.Test.Bytes(bytes))
    }

    public init(utf8 string: Swift.String) {
        self.init(Parser.Test.Bytes([UInt8](string.utf8)))
    }
}

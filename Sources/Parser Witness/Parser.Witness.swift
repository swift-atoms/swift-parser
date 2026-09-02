public import Parser

extension Parser {

    public struct Witness<Input: ~Copyable & ~Escapable, Output, Failure: Swift.Error>: Parser.`Protocol` {

        public var _parse: (inout Input) throws(Failure) -> Output

        @inlinable
        public init(_ parse: @escaping (inout Input) throws(Failure) -> Output) {
            self._parse = parse
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try _parse(&input)
        }
    }

    public typealias Pure<Input, Output> = Witness<Input, Output, Never>
    where Input: ~Copyable & ~Escapable
}

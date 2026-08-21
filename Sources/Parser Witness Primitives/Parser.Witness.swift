extension Parser {

    public struct Witness<Input: ~Copyable & ~Escapable, Output, Failure: Swift.Error> {

        public var _parse: (inout Input) throws(Failure) -> Output

        @inlinable
        public init(_ parse: @escaping (inout Input) throws(Failure) -> Output) {
            self._parse = parse
        }
    }

    public typealias Pure<Input, Output> = Witness<Input, Output, Never>
    where Input: ~Copyable & ~Escapable
}

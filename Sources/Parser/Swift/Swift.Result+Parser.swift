extension Swift.Result
where
Success: Parser::Parsing & ~Copyable,
Success.Input: ~Copyable & ~Escapable,
Success.Output: ~Copyable & ~Escapable,
Success.Failure == Failure
{

    public struct Parser: Parser::Parsing, ~Copyable {
        public typealias Input = Success.Input
        public typealias Output = Success.Output
        
        public let wrapped: Swift.Result<Success, Failure>
        
        @inlinable
        public init(_ wrapped: consuming Swift.Result<Success, Failure>) {
            self.wrapped = wrapped
        }
        
        @inlinable
        @_lifetime(borrow self, &input)
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            switch wrapped {
            case .success(let parser):
                return try parser.parse(&input)
            case .failure(let error):
                throw error
            }
        }
    }
}

extension Swift.Result.Parser: Copyable
where Success: Copyable, Success.Input: ~Copyable & ~Escapable,
      Success.Output: ~Copyable & ~Escapable, Success.Failure == Failure {}

extension Parser::Builder where Input: ~Copyable & ~Escapable {
    @inlinable
    public static func buildExpression<P: Parser::Parsing & ~Copyable>(
        _ result: consuming Swift.Result<P, P.Failure>
    ) -> Swift.Result<P, P.Failure>.Parser
    where P.Input == Input, P.Input: ~Copyable & ~Escapable,
          P.Output: ~Copyable & ~Escapable {
              .init(result)
          }
}

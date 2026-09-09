#if Lazy
public import Lazy
public import Either

extension Lazy::Lazy
where
    Value: Parser::Parsing & ~Copyable,
    Value.Input: ~Copyable & ~Escapable,
    Value.Output: ~Copyable & Escapable
{
    /// Creates a temporary parser per call; its output must not borrow that parser.
    public struct Parser<Failure: Swift.Error>: Parser::Parsing {
        public typealias Input = Value.Input
        public typealias Output = Value.Output

        public let wrapped: Lazy::Lazy<Value, FactoryFailure>
        @usableFromInline internal let factoryFailure: (FactoryFailure) -> Failure
        @usableFromInline internal let parseFailure: (Value.Failure) -> Failure

        @inlinable
        public init(_ wrapped: Lazy::Lazy<Value, FactoryFailure>)
        where FactoryFailure == Never, Failure == Value.Failure {
            self.wrapped = wrapped
            self.factoryFailure = { $0 }
            self.parseFailure = { $0 }
        }

        @inlinable
        public init(_ wrapped: Lazy::Lazy<Value, FactoryFailure>)
        where Failure == Either<FactoryFailure, Value.Failure> {
            self.wrapped = wrapped
            self.factoryFailure = { .left($0) }
            self.parseFailure = { .right($0) }
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let parser: Value
            do throws(FactoryFailure) {
                parser = try wrapped()
            } catch {
                throw factoryFailure(error)
            }
            do throws(Value.Failure) {
                return try parser.parse(&input)
            } catch {
                throw parseFailure(error)
            }
        }
    }

    @inlinable
    public func parser() -> Parser<Either<FactoryFailure, Value.Failure>> {
        .init(self)
    }

    @inlinable
    public func parser() -> Parser<Value.Failure> where FactoryFailure == Never {
        .init(self)
    }
}
#endif

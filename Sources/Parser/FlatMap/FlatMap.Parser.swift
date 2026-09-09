#if FlatMap
public import FlatMap
public import Either

extension FlatMap
where
    Source: ~Copyable & ~Escapable,
    Continuation: Parsing & ~Copyable,
    Continuation.Input: ~Copyable & ~Escapable,
    Continuation.Output: ~Copyable & Escapable
{

    public struct Parser<Upstream: Parsing & ~Copyable>: Parsing, ~Copyable
    where
        Upstream.Input == Continuation.Input,
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable,
        Upstream.Output == Source
    {
        public typealias Input = Upstream.Input
        public typealias Output = Continuation.Output
        public typealias Failure = Either<Upstream.Failure, Continuation.Failure>

        public let base: FlatMap
        public let upstream: Upstream

        @inlinable
        public init(_ base: FlatMap, upstream: consuming Upstream) {
            self.base = base
            self.upstream = upstream
        }

        @inlinable
        public init(
            upstream: consuming Upstream,
            transform: @escaping (consuming Source) -> Continuation
        ) {
            self.init(FlatMap(transform), upstream: upstream)
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let value: Source
            do throws(Upstream.Failure) {
                value = try upstream.parse(&input)
            } catch {
                throw .left(error)
            }
            let downstream = base(value)
            do throws(Continuation.Failure) {
                return try downstream.parse(&input)
            } catch {
                throw .right(error)
            }
        }
    }

    @inlinable
    public func parser<P: Parsing & ~Copyable>(_ upstream: consuming P) -> Parser<P>
    where
        P.Input == Continuation.Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable,
        P.Output == Source
    {
        .init(self, upstream: upstream)
    }
}

extension FlatMap.Parser: Copyable
where
    Source: ~Copyable & ~Escapable,
    Continuation: Parsing<Continuation.Input, Continuation.Output, Continuation.Failure> & ~Copyable,
    Continuation.Input: ~Copyable & ~Escapable,
    Continuation.Output: ~Copyable & Escapable,
    Upstream: Parsing<Upstream.Input, Upstream.Output, Upstream.Failure> & Copyable,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable
{}

#endif

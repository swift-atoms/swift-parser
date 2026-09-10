#if Map
public import Map

extension Map
where Source: ~Copyable & ~Escapable, Target: ~Copyable & Escapable {

    @frozen
    public struct Parser<Upstream: Parsing & ~Copyable>: Parsing, ~Copyable
    where
        Upstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable,
        Upstream.Output == Source
    {
        public typealias Input = Upstream.Input
        public typealias Output = Target

        public let base: Map
        public let upstream: Upstream
        public let failure: (Upstream.Failure) -> Failure

        @inlinable
        public init(
            _ base: Map,
            upstream: consuming Upstream,
            failure: @escaping (Upstream.Failure) -> Failure
        ) {
            self.base = base
            self.upstream = upstream
            self.failure = failure
        }

        @inlinable
        public init(
            upstream: consuming Upstream,
            transform: @escaping (consuming Source) throws(Failure) -> Target,
            failure: @escaping (Upstream.Failure) -> Failure
        ) {
            self.init(Map(transform), upstream: upstream, failure: failure)
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Target {
            let value: Source
            do throws(Upstream.Failure) {
                value = try upstream.parse(&input)
            } catch {
                throw failure(error)
            }
            return try base(value)
        }
    }

    @inlinable
    public func parser<P: Parsing & ~Copyable>(
        _ upstream: consuming P,
        failure: @escaping (P.Failure) -> Failure
    ) -> Parser<P>
    where
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable,
        P.Output == Source
    {
        .init(self, upstream: upstream, failure: failure)
    }

    @inlinable
    public func parser<P: Parsing & ~Copyable>(_ upstream: consuming P) -> Parser<P>
    where
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable,
        P.Output == Source,
        P.Failure == Failure
    {
        .init(self, upstream: upstream, failure: { $0 })
    }
}

extension Map.Parser: Copyable
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Upstream: Parsing<Upstream.Input, Upstream.Output, Upstream.Failure> & Copyable,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable
{}

#endif

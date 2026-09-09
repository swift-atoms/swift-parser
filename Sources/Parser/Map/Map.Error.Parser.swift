#if Map
public import Map

extension Map where Source: Swift.Error, Target: Swift.Error, Failure == Never {

    public enum Error {

        /// Maps only an upstream parser's failure. Successful values and their
        /// lifetime dependencies pass through unchanged; input is not rewound.
        public struct Parser<Upstream: Parsing & ~Copyable>: Parsing, ~Copyable
        where
            Upstream.Input: ~Copyable & ~Escapable,
            Upstream.Output: ~Copyable & ~Escapable,
            Upstream.Failure == Source
        {
            public typealias Input = Upstream.Input
            public typealias Output = Upstream.Output
            public typealias Failure = Target

            public let base: Map
            public let upstream: Upstream

            @inlinable
            public init(_ base: Map, _ upstream: consuming Upstream) {
                self.base = base
                self.upstream = upstream
            }

            @inlinable
            @_lifetime(borrow self, &input)
            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                do throws(Upstream.Failure) {
                    return try upstream.parse(&input)
                } catch {
                    throw base(error)
                }
            }
        }
    }

    @inlinable
    public func errorParser<P: Parsing & ~Copyable>(_ upstream: consuming P) -> Error.Parser<P>
    where
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable,
        P.Failure == Source
    {
        .init(self, upstream)
    }
}

extension Map.Error.Parser: Copyable
where
    Upstream: Parsing<Upstream.Input, Upstream.Output, Upstream.Failure> & Copyable,
    Upstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable
{}

#endif

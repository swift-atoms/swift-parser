extension Map
where Source: Parsing & ~Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable {
    /// Transforms the upstream output while preserving input consumption.
    @frozen
    public struct Parser<Target: ~Copyable, Failure: Swift.Error>: Parsing, ~Copyable {
        public typealias Input = Source.Input
        public typealias Output = Target

        public let base: Map<Source.Output>.Transform<Target, Failure>
        public let upstream: Source
        public let failure: (Source.Failure) -> Failure

        @inlinable
        public init(
            _ base: Map<Source.Output>.Transform<Target, Failure>,
            upstream: consuming Source,
            failure: @escaping (Source.Failure) -> Failure
        ) {
            self.base = base
            self.upstream = upstream
            self.failure = failure
        }

        @inlinable
        public init(
            upstream: consuming Source,
            transform: @escaping (consuming Source.Output) throws(Failure) -> Target,
            failure: @escaping (Source.Failure) -> Failure
        ) {
            self.init(.init(transform), upstream: upstream, failure: failure)
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Target {
            let value: Source.Output
            do throws(Source.Failure) {
                value = try upstream.parse(&input)
            } catch {
                throw failure(error)
            }
            return try base(value)
        }
    }
}

extension Map.Parser: Copyable
where Source: Parsing<Source.Input, Source.Output, Source.Failure> & Copyable,
    Source.Input: ~Copyable & ~Escapable,
    Source.Output: ~Copyable & ~Escapable,
    Target: ~Copyable {}

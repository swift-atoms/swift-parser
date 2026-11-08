#if FlatMap
    public import Parser_Core
    public import FlatMap

    extension Parsing
    where
        Self: ~Copyable,
        Input: ~Copyable & ~Escapable,
        Output: ~Copyable & ~Escapable
    {

        @inlinable
        public consuming func flatMap<P: Parsing & ~Copyable>(
            _ transform: @escaping (consuming Output) -> P
        ) -> FlatMap::FlatMap<Output, P>.Parser<Self>
        where
            P.Input == Input,
            P.Input: ~Copyable & ~Escapable,
            P.Output: ~Copyable & Escapable
        {
            .init(upstream: self, transform: transform)
        }
    }

#endif

#if Map
    public import Parser_Core
    public import Map

    extension Parsing
    where
        Self: ~Copyable,
        Input: ~Copyable & ~Escapable,
        Output: ~Copyable & ~Escapable
    {

        @inlinable
        public consuming func mapFailure<NewFailure: Swift::Error>(
            _ transform: @escaping (Failure) -> NewFailure
        ) -> Map::Map<Failure, NewFailure, Never>.Error.Parser<Self> {
            Map::Map<Failure, NewFailure, Never>(transform).errorParser(self)
        }
    }

#endif

#if Optic
    public import Parser_Core
    public import Either
    public import Optic

    extension Parser::Parsing
    where
        Self: ~Copyable,
        Input: ~Copyable & ~Escapable,
        Output: ~Copyable & ~Escapable
    {

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable,
            BackwardFailure: Swift::Error
        >(
            forward adapter: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Adapter<Never, BackwardFailure>
        ) -> Map::Map<Self.Output, Focus, Never>.Parser<Self>
        where Output == Source, Failure == Never {
            map { source in adapter.forward(source) }
        }

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable,
            BackwardFailure: Swift::Error
        >(
            forward adapter: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Adapter<Never, BackwardFailure>
        ) -> Map::Map<Self.Output, Focus, Failure>.Parser<Self>
        where Output == Source {
            map { source in adapter.forward(source) }
        }

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable,
            ForwardFailure: Swift::Error,
            BackwardFailure: Swift::Error
        >(
            forward adapter: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Adapter<ForwardFailure, BackwardFailure>
        ) -> Map::Map<Self.Output, Focus, ForwardFailure>.Parser<Self>
        where Output == Source, Failure == Never {
            map(adapter.forward)
        }

        @_disfavoredOverload
        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable,
            ForwardFailure: Swift::Error,
            BackwardFailure: Swift::Error
        >(
            forward adapter: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Adapter<ForwardFailure, BackwardFailure>
        ) -> Map::Map<Self.Output, Focus, Either<Failure, ForwardFailure>>.Parser<Self>
        where Output == Source {
            map(adapter.forward)
        }
    }

#endif

#if Optic
    public import Parser_Core
    public import Optic

    extension Parser::Parsing
    where
        Self: ~Copyable,
        Input: ~Copyable & ~Escapable,
        Output: ~Copyable & ~Escapable
    {

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable
        >(
            forward isomorphism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Isomorphism
        ) -> Map::Map<Self.Output, Focus, Failure>.Parser<Self>
        where Output == Source {
            map(isomorphism.forward)
        }
    }

#endif

#if Optic
    public import Parser_Core
    public import Either
    public import Optic

    extension Parser::Parsing
    where
        Self: ~Copyable,
        Input: ~Copyable & ~Escapable,
        Output: ~Copyable & ~Escapable
    {

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable
        >(
            matching prism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Prism
        ) -> Map::Map<Self.Output, Either<Target, Focus>, Failure>.Parser<Self>
        where Output == Source {
            map(prism.match)
        }

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable
        >(
            matching prism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Prism,
            failure transform: @escaping (consuming Target) -> Never
        ) -> Map::Map<Self.Output, Focus, Never>.Parser<Self>
        where Output == Source, Failure == Never {
            map { source in
                switch prism.match(source) {
                case .left(let target):
                    transform(target)
                case .right(let focus):
                    focus
                }
            }
        }

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable
        >(
            matching prism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Prism,
            failure transform: @escaping (consuming Target) -> Never
        ) -> Map::Map<Self.Output, Focus, Failure>.Parser<Self>
        where Output == Source {
            map { source in
                switch prism.match(source) {
                case .left(let target):
                    transform(target)
                case .right(let focus):
                    focus
                }
            }
        }

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable,
            MatchFailure: Swift::Error
        >(
            matching prism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Prism,
            failure transform: @escaping (consuming Target) -> MatchFailure
        ) -> Map::Map<Self.Output, Focus, MatchFailure>.Parser<Self>
        where Output == Source, Failure == Never {
            map { source throws(MatchFailure) in
                switch prism.match(source) {
                case .left(let target):
                    throw transform(target)
                case .right(let focus):
                    return focus
                }
            }
        }

        @_disfavoredOverload
        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable,
            MatchFailure: Swift::Error
        >(
            matching prism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Prism,
            failure transform: @escaping (consuming Target) -> MatchFailure
        ) -> Map::Map<Self.Output, Focus, Either<Failure, MatchFailure>>.Parser<Self>
        where Output == Source {
            map { source throws(MatchFailure) in
                switch prism.match(source) {
                case .left(let target):
                    throw transform(target)
                case .right(let focus):
                    return focus
                }
            }
        }

        @inlinable
        public consuming func map<
            Source: ~Copyable & ~Escapable,
            Target: ~Copyable & Escapable,
            Focus: ~Copyable & Escapable,
            Replacement: ~Copyable & ~Escapable
        >(
            embedding prism: Optic::Optic<
                Source,
                Target,
                Focus,
                Replacement
            >.Prism
        ) -> Map::Map<Self.Output, Target, Failure>.Parser<Self>
        where Output == Replacement {
            map(prism.embed)
        }
    }

#endif

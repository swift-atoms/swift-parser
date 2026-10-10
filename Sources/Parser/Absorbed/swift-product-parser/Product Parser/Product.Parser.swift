#if Product
import Parser_Core
#if hasFeature(MoveOnlyTuples) && hasFeature(NoncopyablePacks)

    public import Product

    extension Product::Product
    where
        repeat each Element: Parser::Parsing & ~Copyable,
        repeat (each Element).Output: Escapable
    {

        @frozen
        public struct Parser<
            Input: ~Copyable & ~Escapable,
            Failure: Swift.Error
        >: ~Copyable
        where repeat (each Element).Input == Input {
            @usableFromInline
            internal let upstream: Product::Product<repeat each Element>

            @usableFromInline
            internal let failure: Product::Product<
                repeat ((each Element).Failure) -> Failure
            >

            @inlinable
            public init(
                upstream: consuming Product::Product<repeat each Element>,
                failure: consuming Product::Product<
                    repeat ((each Element).Failure) -> Failure
                >
            ) {
                self.upstream = upstream
                self.failure = failure
            }
        }
    }

    extension Product::Product.Parser: Copyable
    where
        repeat each Element: Copyable,
        Failure: Copyable
    {}

    extension Product::Product.Parser: Parser::Parsing
    where repeat each Element: ~Copyable {

        public typealias Output = Product::Product<
            repeat (each Element).Output
        >

        public typealias Body = Never

        @inlinable
        public borrowing func parse(
            _ input: inout Input
        ) throws(Failure) -> Output {
            Product::Product<repeat (each Element).Output>(
                repeat try parse(
                    each upstream.values,
                    failure: each failure.values,
                    input: &input
                )
            )
        }

        @usableFromInline
        @inlinable
        internal borrowing func parse<
            Upstream: Parser::Parsing & ~Copyable
        >(
            _ upstream: borrowing Upstream,
            failure: (Upstream.Failure) -> Failure,
            input: inout Input
        ) throws(Failure) -> Upstream.Output
        where Upstream.Input == Input, Upstream.Output: Escapable {
            do throws(Upstream.Failure) {
                return try upstream.parse(&input)
            } catch {
                throw failure(error)
            }
        }
    }
#endif
#endif

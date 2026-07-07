// Tagged+Parseable.swift
// swift-parser-primitives
//
// Canonical generic Parseable conformance for Tagged. Tagged<Tag, Underlying>
// is Parseable when Underlying is — its parsing delegates to the underlying
// value's canonical parser, then wraps the result in Tagged via the
// `_unchecked` initializer (parse semantics: the underlying parser produces
// a valid Underlying; tagging is a phantom-type lift, no validation).
//
// This is domain-agnostic: Tagged becomes Parseable for ANY Underlying that
// is Parseable — binary-domain (`Underlying.Parser == Binary.Parser<Underlying>`),
// text-domain, future parser flavors all work uniformly.

public import Parser_Primitive
public import Tagged_Primitives

extension Tagged where Underlying: Parseable, Underlying.Parser.Output == Underlying {
    /// Wrapper parser that lifts `Underlying.Parser` to produce `Tagged<Tag, Underlying>`
    /// values.
    ///
    /// `parse(_:)` runs the underlying parser then wraps the result via the
    /// `_unchecked:` initializer. The Input and Failure types are inherited
    /// from the underlying's parser — Tagged adds no input-shape or error
    /// concerns of its own.
    public struct UnderlyingParser: Parser_Primitive.Parser.`Protocol` {
        /// The input type this parser consumes.
        public typealias Input = Underlying.Parser.Input
        /// The output type this parser produces: the tagged wrapper value.
        public typealias Output = Tagged<Tag, Underlying>
        /// The error type this parser can throw, inherited from the underlying parser.
        public typealias Failure = Underlying.Parser.Failure
        /// A leaf parser has no composed body.
        public typealias Body = Never

        /// Creates the wrapper parser.
        @inlinable
        public init() {}

        /// Runs the underlying parser, then lifts its result into a tagged value.
        @inlinable
        public borrowing func parse(
            _ input: inout Underlying.Parser.Input
        ) throws(Underlying.Parser.Failure) -> Tagged<Tag, Underlying> {
            let underlying = try Underlying.parser.parse(&input)
            return Tagged<Tag, Underlying>(_unchecked: underlying)
        }
    }
}

extension Tagged: Parseable
where
    Underlying: Parseable,
    Underlying.Parser.Output == Underlying
{
    /// The canonical parser that lifts the underlying value's parser to produce tagged values.
    @inlinable
    public static var parser: Tagged<Tag, Underlying>.UnderlyingParser {
        Tagged<Tag, Underlying>.UnderlyingParser()
    }
}

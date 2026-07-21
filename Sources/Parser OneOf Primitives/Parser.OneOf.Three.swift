//
//  Parser.OneOf.Three.swift
//  swift-standards
//
//  Three-parser alternative combinator.
//

public import Input_Primitives
public import Product_Primitives

extension Parser.OneOf {
    /// A parser that tries three alternatives.
    public struct Three<P0: Parser.`Protocol`, P1: Parser.`Protocol`, P2: Parser.`Protocol`>
    where
        P0.Input == P1.Input,
        P1.Input == P2.Input,
        P0.Output == P1.Output,
        P1.Output == P2.Output,
        P0.Input: Input_Primitives.Input.`Protocol`
    {
        @usableFromInline
        let p0: P0

        @usableFromInline
        let p1: P1

        @usableFromInline
        let p2: P2

        /// Creates a parser that tries the three parsers in order.
        @inlinable
        public init(_ p0: P0, _ p1: P1, _ p2: P2) {
            self.p0 = p0
            self.p1 = p1
            self.p2 = p2
        }
    }
}

extension Parser.OneOf.Three: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = P0.Input
    /// The output type all three alternatives produce.
    public typealias Output = P0.Output
    /// The error type this parser can throw, combining all three alternatives' errors.
    public typealias Failure = Product<P0.Failure, P1.Failure, P2.Failure>

    /// Tries each parser in order, backtracking between attempts, until one succeeds.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let checkpoint = input.checkpoint

        do throws(P0.Failure) { return try p0.parse(&input) } catch let error0 {
            input.restore.to(__unchecked: (), checkpoint)
            do throws(P1.Failure) { return try p1.parse(&input) } catch let error1 {
                input.restore.to(__unchecked: (), checkpoint)
                do throws(P2.Failure) { return try p2.parse(&input) } catch let error2 {
                    throw Failure(error0, error1, error2)
                }
            }
        }
    }
}

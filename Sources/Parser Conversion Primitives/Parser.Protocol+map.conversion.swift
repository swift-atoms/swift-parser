//
//  Parser.Protocol+map.conversion.swift
//  swift-parser-primitives
//
//  The printability-preserving `map(conversion)` on Parser.Protocol.
//

extension Parser.`Protocol` {
    /// Transforms this parser's output through a conversion, preserving
    /// printability.
    ///
    /// This is the printer-friendly counterpart to `map { transform($0) }`.
    /// Where the closure `map` yields a parse-only parser, this overload yields
    /// a ``Parser/Converted`` that parses via the conversion's
    /// ``Parser/Conversion/Protocol/apply(_:)`` and — when this parser is a
    /// ``Parser/Printer`` — prints via its
    /// ``Parser/Conversion/Protocol/unapply(_:)``. When this parser is
    /// ``Parser/Bidirectional``, so is the result.
    ///
    /// The conversion overload is distinguished from the closure overloads by
    /// its argument: a conversion is a value, not a function.
    ///
    /// - Parameter conversion: A conversion from this parser's `Output`.
    /// - Returns: A parser-printer over the converted output.
    @inlinable
    public func map<Downstream: Parser.Conversion.`Protocol`>(
        _ conversion: Downstream
    ) -> Parser.Converted<Self, Downstream>
    where Downstream.Input == Output {
        .init(upstream: self, downstream: conversion)
    }
}

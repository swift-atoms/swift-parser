//
//  Parser.Conversion.swift
//  swift-parser-primitives
//
//  Bidirectional value-conversion namespace for parser-printers.
//

extension Parser {
    /// Namespace for bidirectional value conversions.
    ///
    /// A conversion transforms an `Input` value into an `Output` value *and*
    /// transforms an `Output` value back into an `Input` value. Conversions are
    /// the keystone that lets a `Parser.Bidirectional` (the Coder-based form in swift-coder-primitives) parser-printer change
    /// its `Output` type while preserving printability: parsing runs the
    /// conversion's ``Parser/Conversion/Protocol/apply(_:)`` forward, printing
    /// runs its ``Parser/Conversion/Protocol/unapply(_:)`` in reverse.
    ///
    /// The conversion combinators nest under this namespace:
    /// - ``Parser/Conversion/Identity`` — the no-op conversion.
    /// - ``Parser/Conversion/Map`` — composes two conversions (`conversion.map(conversion)`).
    /// - ``Parser/Conversion/Witness`` — closure-backed escape hatch.
    /// - ``Parser/Conversion/Memberwise`` — tuple ⇆ struct via explicit embed/project.
    /// - ``Parser/Conversion/RawValue`` — raw value ⇆ `RawRepresentable`.
    /// - ``Parser/Conversion/Fixed`` — `Void` ⇆ a constant value.
    /// - ``Parser/Conversion/Case`` — enum-case payload ⇆ enum.
    ///
    /// Applying a conversion to a parser-printer is spelled `parser.map(conversion)`,
    /// which yields a ``Parser/Converted`` parser that is itself
    /// `Parser.Bidirectional` (the Coder-based form in swift-coder-primitives) whenever the upstream is.
    ///
    /// ## Naming precedent
    ///
    /// `Parser.Conversion` mirrors the `Parser` namespace shape: just as `Parser`
    /// is an `enum` holding `Parser.Protocol`, `Parser.Conversion` is an `enum`
    /// holding ``Parser/Conversion/Protocol``. The combinator structs nest under
    /// it exactly as `Parser.Map` / `Parser.Take` nest under `Parser`.
    ///
    /// ## External conformers
    ///
    /// ``Parser/Conversion/Protocol`` is deliberately open: a case-path bridge
    /// (e.g. an `AnyCasePath`) can conform from outside the package by
    /// implementing `apply` (extract, failable) and `unapply` (embed). No
    /// case-path dependency is taken here.
    public enum Conversion {}
}

//
//  Parser.Conversion.Case.swift
//  swift-parser-primitives
//
//  Enum-case payload ⇆ enum conversion.
//

extension Parser.Conversion {
    /// A conversion between an enum case's payload and the enum itself.
    ///
    /// The forward direction embeds a payload `Value` into a `Root` enum case;
    /// the reverse direction extracts the payload back out, failing when the
    /// `Root` holds a different case. This is the printer-friendly way to lift a
    /// payload parser-printer into an enum: parsing embeds the parsed payload
    /// into its case, printing extracts the payload (or fails when the case does
    /// not match).
    ///
    /// `Case` is the closure-only, dependency-free core of enum-case addressing.
    /// A case path — its `embed`/`extract` pair — supplied from *outside* the
    /// package (a macro-generated accessor, an `AnyCasePath` bridge) is passed as
    /// the two closures. No case-path type is referenced here; the conversion
    /// sees only closures.
    ///
    /// ```swift
    /// enum Route: Equatable { case home; case detail(Int) }
    ///
    /// // Int -> Route.detail, and back
    /// let detail = intParser.map(
    ///     .case(embed: Route.detail, extract: { if case let .detail(id) = $0 { id } else { nil } })
    /// )
    /// ```
    ///
    /// Created via ``Parser/Conversion/Protocol/case(embed:extract:)``.
    ///
    /// ## Duality
    ///
    /// `apply` (embed) is **total** — every payload has an enum case. `unapply`
    /// (extract) is **partial** — it raises ``Parser/Conversion/Error/absentCase``
    /// when the `Root` holds a case other than the one this conversion addresses.
    /// This mirrors the failable-reverse shape of ``Parser/Conversion/Fixed``.
    public struct Case<Root, Value> {
        @usableFromInline
        internal let embed: (Value) -> Root

        @usableFromInline
        internal let extract: (Root) -> Value?

        /// Creates an enum-case conversion from an embed/extract closure pair.
        ///
        /// - Parameters:
        ///   - embed: Builds the enum from the case payload.
        ///   - extract: Recovers the case payload from the enum, or `nil` when the
        ///     enum holds a different case.
        @inlinable
        public init(
            embed: @escaping (Value) -> Root,
            extract: @escaping (Root) -> Value?
        ) {
            self.embed = embed
            self.extract = extract
        }
    }
}

extension Parser.Conversion.Case: Parser.Conversion.`Protocol` {
    /// The case payload this conversion converts from.
    public typealias Input = Value
    /// The enum this conversion converts to.
    public typealias Output = Root
    /// Partial: `unapply` fails when the enum holds a different case.
    public typealias Failure = Parser.Conversion.Error

    /// Embeds the payload into its enum case.
    @inlinable
    public func apply(_ input: Value) -> Root { embed(input) }

    /// Extracts the payload from the enum.
    ///
    /// - Throws: ``Parser/Conversion/Error/absentCase`` when the enum holds a
    ///   case other than the one this conversion addresses.
    @inlinable
    public func unapply(_ output: Root) throws(Parser.Conversion.Error) -> Value {
        guard let value = extract(output) else {
            throw .absentCase
        }
        return value
    }
}

extension Parser.Conversion.`Protocol` {
    /// A conversion between an enum case's payload and the enum.
    ///
    /// - Parameters:
    ///   - embed: Builds the enum from the case payload (`apply`, total).
    ///   - extract: Recovers the case payload from the enum, or `nil` when the
    ///     enum holds a different case (`unapply`, partial).
    /// - Returns: A conversion from the payload to the enum.
    @inlinable
    public static func `case`<Root, Value>(
        embed: @escaping (Value) -> Root,
        extract: @escaping (Root) -> Value?
    ) -> Self where Self == Parser.Conversion.Case<Root, Value> {
        .init(embed: embed, extract: extract)
    }
}

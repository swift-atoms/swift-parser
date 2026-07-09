//
//  Parser.Conversion.Memberwise.swift
//  swift-parser-primitives
//
//  Tuple ⇆ struct conversion via an explicit embed/project pair.
//

extension Parser.Conversion {
    /// A conversion between a tuple of values and a struct.
    ///
    /// The forward direction embeds a tuple of parsed fields into a struct
    /// (typically the memberwise initializer); the reverse direction projects
    /// the struct back into the tuple. Both directions are supplied explicitly,
    /// which keeps the conversion **total and memory-safe**.
    ///
    /// ```swift
    /// struct Point { var x: Int; var y: Int }
    ///
    /// let point = Parser.Take.Two(digit, digit)
    ///     .map(.memberwise(
    ///         { Point(x: $0.0, y: $0.1) },   // embed  (Int, Int) -> Point
    ///         { ($0.x, $0.y) }               // project Point -> (Int, Int)
    ///     ))
    /// ```
    ///
    /// ## Why an explicit project, not `unsafeBitCast`
    ///
    /// The upstream `pointfree` `Conversions.Memberwise` derives the reverse
    /// direction by reinterpreting the struct's bytes as a tuple with
    /// `unsafeBitCast`, guarded by a runtime type-metadata kind check. That is a
    /// documented footgun — it crashes on any initializer that reorders or
    /// changes fields, and reads type metadata (incompatible with
    /// `[PRIM-FOUND-002]` Embedded and `.strictMemorySafety()`). The institute
    /// carve-out for `unsafeBitCast` (`swift-tagged-primitives` Tagged+Literals)
    /// is bounded to *function-reference* reinterpretation, which is ABI-safe;
    /// a *value* struct→tuple reinterpretation is a strictly larger, unauthorized
    /// carve-out. This combinator therefore takes an explicit `project` — safe,
    /// Embedded-clean, and total.
    public struct Memberwise<Values, Struct> {
        @usableFromInline
        internal let embed: (Values) -> Struct

        @usableFromInline
        internal let project: (Struct) -> Values

        /// Creates a memberwise conversion from an embed/project pair.
        ///
        /// - Parameters:
        ///   - embed: Builds a struct from the tuple of field values.
        ///   - project: Destructures a struct into its tuple of field values.
        @inlinable
        public init(
            embed: @escaping (Values) -> Struct,
            project: @escaping (Struct) -> Values
        ) {
            self.embed = embed
            self.project = project
        }
    }
}

extension Parser.Conversion.Memberwise: Parser.Conversion.`Protocol` {
    /// The tuple of field values this conversion converts from.
    public typealias Input = Values
    /// The struct this conversion converts to.
    public typealias Output = Struct
    /// This conversion is total.
    public typealias Failure = Never

    /// Embeds the tuple of field values into a struct.
    @inlinable
    public func apply(_ input: Values) -> Struct { embed(input) }

    /// Projects the struct back into its tuple of field values.
    @inlinable
    public func unapply(_ output: Struct) -> Values { project(output) }
}

extension Parser.Conversion.`Protocol` {
    /// A conversion between a tuple of values and a struct.
    ///
    /// - Parameters:
    ///   - embed: Builds a struct from the tuple of field values.
    ///   - project: Destructures a struct into its tuple of field values.
    /// - Returns: A memberwise conversion.
    @inlinable
    public static func memberwise<Values, Struct>(
        _ embed: @escaping (Values) -> Struct,
        _ project: @escaping (Struct) -> Values
    ) -> Self where Self == Parser.Conversion.Memberwise<Values, Struct> {
        .init(embed: embed, project: project)
    }
}

//
//  Parser.Many.Separated.swift
//  swift-parser-primitives
//
//  Repetition parser with separators.
//

public import Input_Primitives

extension Parser.Many {
    /// A parser that applies another parser repeatedly with separators.
    ///
    /// `Separated` collects results into an array. It always succeeds (possibly with
    /// an empty array) unless a minimum count is specified.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Comma-separated values
    /// let csv = Parser.Many.Separated {
    ///     Field()
    /// } separator: {
    ///     ","
    /// }
    ///
    /// // One or more with separator
    /// let list = Parser.Many.Separated(1...) {
    ///     Int.parser()
    /// } separator: {
    ///     ","
    /// }
    /// ```
    ///
    /// ## Shared generics
    ///
    /// `Input` and `Element` are inherited from the outer ``Parser/Many``;
    /// only the `Separator` parameter is added at this nesting level.
    public struct Separated<Separator: Parser.`Protocol`>
    where Separator.Input == Input {
        @usableFromInline
        let element: Element

        @usableFromInline
        let separator: Separator

        @usableFromInline
        let minimum: Int

        /// `Int.max` means no maximum.
        @usableFromInline
        let maximum: Int

        /// Creates a separated parser requiring at least the range's lower bound elements.
        @inlinable
        public init(
            _ range: PartialRangeFrom<Int>,
            @Parser.Take.Builder<Input> element: () -> Element,
            @Parser.Take.Builder<Input> separator: () -> Separator
        ) {
            self.element = element()
            self.separator = separator()
            self.minimum = range.lowerBound
            self.maximum = .max
        }

        /// Creates a separated parser accepting an element count within the given range.
        @inlinable
        public init(
            _ range: ClosedRange<Int>,
            @Parser.Take.Builder<Input> element: () -> Element,
            @Parser.Take.Builder<Input> separator: () -> Separator
        ) {
            self.element = element()
            self.separator = separator()
            self.minimum = range.lowerBound
            self.maximum = range.upperBound
        }

        /// Creates a separated parser accepting zero or more elements.
        @inlinable
        public init(
            @Parser.Take.Builder<Input> element: () -> Element,
            @Parser.Take.Builder<Input> separator: () -> Separator
        ) {
            self.element = element()
            self.separator = separator()
            self.minimum = 0
            self.maximum = .max
        }
    }
}

extension Parser.Many.Separated: Parser.`Protocol` {
    /// The output type this parser produces: an array of element outputs.
    public typealias Output = [Element.Output]
    /// The error type this parser can throw when the element count is out of range.
    public typealias Failure = Parser.Many<Input, Element>.Error

    /// Parses elements separated by the separator, collecting outputs into an array.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        var results: [Element.Output] = []
        if maximum < .max {
            results.reserveCapacity(maximum)
        } else if minimum > 0 {
            results.reserveCapacity(minimum)
        }

        do throws(Element.Failure) {
            let first = try element.parse(&input)
            results.append(first)
        } catch {
            if minimum > 0 {
                throw Failure.countTooLow(expected: minimum, got: 0)
            }
            return results
        }

        while results.count < maximum {
            let checkpoint = input.checkpoint

            do throws(Separator.Failure) {
                _ = try separator.parse(&input)
            } catch {
                input.restore.to(__unchecked: (), checkpoint)
                break
            }

            do throws(Element.Failure) {
                let next = try element.parse(&input)
                results.append(next)
            } catch {
                input.restore.to(__unchecked: (), checkpoint)
                break
            }
        }

        if results.count < minimum {
            throw Failure.countTooLow(expected: minimum, got: results.count)
        }

        return results
    }
}

// MARK: - Printer Conformance

extension Parser.Many.Separated: Parser.Printer
where Element: Parser.Printer, Separator: Parser.Printer, Separator.Output == Void {
    /// Prints each element in reverse, inserting the separator between successive elements.
    @inlinable
    public func print(_ output: [Element.Output], into input: inout Input) throws(Failure) {
        if output.count < minimum {
            throw Failure.countTooLow(expected: minimum, got: output.count)
        }
        if maximum < .max, output.count > maximum {
            throw Failure.countTooHigh(expected: maximum, got: output.count)
        }

        var isFirst = true
        for item in output.reversed() {
            if !isFirst {
                do throws(Separator.Failure) {
                    try separator.print((), into: &input)
                } catch {
                    break
                }
            }
            do throws(Element.Failure) {
                try element.print(item, into: &input)
            } catch {
                break
            }
            isFirst = false
        }
    }
}

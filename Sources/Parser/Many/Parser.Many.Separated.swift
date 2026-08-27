public import Input

extension Parser.Many {

    public struct Separated<Separator: Parser.`Protocol`>
    where Separator.Input == Input {

        public let element: Element

        public let separator: Separator

        public let minimum: Int

        public let maximum: Int

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

    public typealias Output = [Element.Output]

    public typealias Failure = Parser.Many<Input, Element>.Error

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
                input.seek(to: checkpoint)
                break
            }

            do throws(Element.Failure) {
                let next = try element.parse(&input)
                results.append(next)
            } catch {
                input.seek(to: checkpoint)
                break
            }
        }

        if results.count < minimum {
            throw Failure.countTooLow(expected: minimum, got: results.count)
        }

        return results
    }
}

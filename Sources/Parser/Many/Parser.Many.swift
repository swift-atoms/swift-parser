public import Input

extension Parser {

    public struct Many<Input: __ParserInput.`Protocol`, Element: Parser.`Protocol`>
    where Element.Input == Input {

        public let element: Element

        public let minimum: Int

        public let maximum: Int

        @inlinable
        public init(
            _ range: PartialRangeFrom<Int>,
            @Parser.Take.Builder<Input> element: () -> Element
        ) {
            self.element = element()
            self.minimum = range.lowerBound
            self.maximum = .max
        }

        @inlinable
        public init(
            _ range: ClosedRange<Int>,
            @Parser.Take.Builder<Input> element: () -> Element
        ) {
            self.element = element()
            self.minimum = range.lowerBound
            self.maximum = range.upperBound
        }

        @inlinable
        public init(
            @Parser.Take.Builder<Input> element: () -> Element
        ) {
            self.element = element()
            self.minimum = 0
            self.maximum = .max
        }
    }
}

extension Parser.Many: Parser.`Protocol` {

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

        while results.count < maximum {
            let checkpoint = input.checkpoint

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

#if Repetition
public import Parser_Core
public import Checkpoint

public struct Many<Source: Restorable & ~Copyable & ~Escapable, Element: Parsing>: Parsing
where Element.Input == Source, Element.Input: ~Copyable & ~Escapable,
      Source.Checkpoint: Equatable, Element.Output: Copyable & Escapable {

    public typealias Input = Source
    public typealias Output = [Element.Output]
    public typealias Failure = Error
    public enum Error: Swift.Error {
        case invalidBounds
        case noProgress
        case countTooLow(expected: Int, got: Int)
        case countTooHigh(expected: Int, got: Int)
        case element(Element.Failure)
    }
    public let element: Element
    public let minimum: Int
    public let maximum: Int
    public let rejected: (Element.Failure) -> Bool
    public init(minimum: Int, maximum: Int, element: Element, rejected: @escaping (Element.Failure) -> Bool) {
        self.minimum = minimum; self.maximum = maximum
        self.element = element; self.rejected = rejected
    }
    public init(_ range: PartialRangeFrom<Int> = 0..., rejected: @escaping (Element.Failure) -> Bool,
                @Builder<Source> element: () -> Element) {
        self.init(minimum: range.lowerBound, maximum: .max, element: element(), rejected: rejected)
    }
    public init(_ range: PartialRangeFrom<Int>, _ element: Element, rejected: @escaping (Element.Failure) -> Bool) {
        self.init(minimum: range.lowerBound, maximum: .max, element: element, rejected: rejected)
    }
    public init(_ range: ClosedRange<Int>, rejected: @escaping (Element.Failure) -> Bool,
                @Builder<Source> element: () -> Element) {
        self.init(minimum: range.lowerBound, maximum: range.upperBound, element: element(), rejected: rejected)
    }
    public init(_ range: ClosedRange<Int>, _ element: Element, rejected: @escaping (Element.Failure) -> Bool) {
        self.init(minimum: range.lowerBound, maximum: range.upperBound, element: element, rejected: rejected)
    }
    public init(_ element: Element, rejected: @escaping (Element.Failure) -> Bool) {
        self.init(minimum: 0, maximum: .max, element: element, rejected: rejected)
    }
    public borrowing func parse(_ input: inout Source) throws(Error) -> Output {
        guard minimum >= 0, maximum >= minimum else { throw .invalidBounds }
        var results: Output = []
        while results.count < maximum {
            let saved = input.checkpoint
            let value: Element.Output
            do throws(Element.Failure) { value = try element.parse(&input) } catch {
                guard rejected(error) else { throw .element(error) }
                input.seek(to: saved)
                break
            }
            guard input.checkpoint != saved else { throw .noProgress }
            results.append(value)
        }
        guard results.count >= minimum else { throw .countTooLow(expected: minimum, got: results.count) }
        return results
    }
}

extension Many where Source: ~Copyable & ~Escapable {
    public struct Separated<Separator: Parsing>: Parsing
    where Separator.Input == Source, Separator.Input: ~Copyable & ~Escapable,
          Separator.Output: ~Copyable & ~Escapable {

        public typealias Input = Source
        public typealias Output = [Element.Output]
        public typealias Failure = Error
        public enum Error: Swift.Error {
            case invalidBounds
            case noProgress
            case countTooLow(expected: Int, got: Int)
            case countTooHigh(expected: Int, got: Int)
            case element(Element.Failure)
            case separator(Separator.Failure)
        }
        public let element: Element
        public let separator: Separator
        public let minimum: Int
        public let maximum: Int
        public let rejected: (Element.Failure) -> Bool
        public let separatorRejected: (Separator.Failure) -> Bool
        public init(minimum: Int, maximum: Int, element: Element, separator: Separator,
                    rejected: @escaping (Element.Failure) -> Bool,
                    separatorRejected: @escaping (Separator.Failure) -> Bool) {
            self.minimum = minimum; self.maximum = maximum
            self.element = element; self.separator = separator
            self.rejected = rejected; self.separatorRejected = separatorRejected
        }
        public init(_ range: PartialRangeFrom<Int> = 0..., rejected: @escaping (Element.Failure) -> Bool,
                    separatorRejected: @escaping (Separator.Failure) -> Bool,
                    @Builder<Source> element: () -> Element, @Builder<Source> separator: () -> Separator) {
            self.init(minimum: range.lowerBound, maximum: .max, element: element(), separator: separator(),
                      rejected: rejected, separatorRejected: separatorRejected)
        }
        public init(_ range: PartialRangeFrom<Int>, _ element: Element, separator: Separator,
                    rejected: @escaping (Element.Failure) -> Bool,
                    separatorRejected: @escaping (Separator.Failure) -> Bool) {
            self.init(minimum: range.lowerBound, maximum: .max, element: element, separator: separator,
                      rejected: rejected, separatorRejected: separatorRejected)
        }
        public init(_ range: ClosedRange<Int>, rejected: @escaping (Element.Failure) -> Bool,
                    separatorRejected: @escaping (Separator.Failure) -> Bool,
                    @Builder<Source> element: () -> Element, @Builder<Source> separator: () -> Separator) {
            self.init(minimum: range.lowerBound, maximum: range.upperBound, element: element(), separator: separator(),
                      rejected: rejected, separatorRejected: separatorRejected)
        }
        public init(_ range: ClosedRange<Int>, _ element: Element, separator: Separator,
                    rejected: @escaping (Element.Failure) -> Bool,
                    separatorRejected: @escaping (Separator.Failure) -> Bool) {
            self.init(minimum: range.lowerBound, maximum: range.upperBound, element: element, separator: separator,
                      rejected: rejected, separatorRejected: separatorRejected)
        }
        public init(_ element: Element, separator: Separator,
                    rejected: @escaping (Element.Failure) -> Bool,
                    separatorRejected: @escaping (Separator.Failure) -> Bool) {
            self.init(minimum: 0, maximum: .max, element: element, separator: separator,
                      rejected: rejected, separatorRejected: separatorRejected)
        }
        public borrowing func parse(_ input: inout Source) throws(Error) -> Output {
            guard minimum >= 0, maximum >= minimum else { throw .invalidBounds }
            var results: Output = []
            while results.count < maximum {
                let saved = input.checkpoint
                if !results.isEmpty {
                    do throws(Separator.Failure) { _ = try separator.parse(&input) } catch {
                        guard separatorRejected(error) else { throw .separator(error) }
                        input.seek(to: saved)
                        break
                    }
                }
                let value: Element.Output
                do throws(Element.Failure) { value = try element.parse(&input) } catch {
                    guard rejected(error) else { throw .element(error) }
                    input.seek(to: saved)
                    break
                }
                guard input.checkpoint != saved else { throw .noProgress }
                results.append(value)
            }
            guard results.count >= minimum else { throw .countTooLow(expected: minimum, got: results.count) }
            return results
        }
    }
}
extension Many.Error: Equatable where Source: ~Copyable & ~Escapable, Element.Failure: Equatable {}
extension Many.Separated.Error: Equatable
where Source: ~Copyable & ~Escapable, Separator.Input: ~Copyable & ~Escapable,
      Separator.Output: ~Copyable & ~Escapable, Element.Failure: Equatable, Separator.Failure: Equatable {}
#endif

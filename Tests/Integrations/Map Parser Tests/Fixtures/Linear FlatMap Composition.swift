import Map
import Parser

struct Input: ~Copyable, ~Escapable {
    let values: Span<Int>
    var index = 0

    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}

struct Value: ~Copyable {
    let number: Int
}

struct Source: ~Copyable, Parsing {
    borrowing func parse(_ input: inout Input) -> Value {
        let result = Value(number: input.values[input.index])
        input.index += 1
        return result
    }
}

struct Destination: ~Copyable, Parsing {
    let seed: Value

    init(_ seed: consuming Value) { self.seed = seed }

    borrowing func parse(_ input: inout Input) -> Value {
        Value(number: seed.number)
    }
}

func composeLinearOwners() throws {
    let source = Source().mapFailure { (error: Never) in error }
    let direct = FlatMap::FlatMap.Parser(upstream: source) { Destination($0) }
    let fluent = Source().flatMap { Destination($0) }
    let values = [3, 4]
    var input = Input(values.span)
    let first = try direct.parse(&input)
    let second = try fluent.parse(&input)
    _ = first.number + second.number
}

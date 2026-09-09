//import Either
//import Parser
//import Testing
//
//@Suite
//struct `Owned mapping properties` {
//    @Test
//    func `stored map and flatMap retain different parser valued semantics`() throws {
//        let mapping = Owned().map
//        let mapped = mapping { Next(value: $0) }
//        var mapInput = 0
//        let value = mapped.parse(&mapInput)
//        #expect(value.value == 1)
//        #expect(mapInput == 1)
//
//        let binding = Owned().flatMap
//        let flattened = binding { Next(value: $0) }
//        var flatInput = 0
//        let output = try flattened.parse(&flatInput)
//        #expect(output == 12)
//        #expect(flatInput == 11)
//    }
//
//    @Test
//    func `named noncopyable owners can be explicitly transferred into stored properties`() throws {
//        let first = Owned()
//        let mapping = (consume first).map
//        let parser = mapping { $0 + 1 }
//        var input = 0
//        #expect(parser.parse(&input) == 2)
//
//        let second = Owned()
//        let binding = (consume second).flatMap
//        let chained = binding { Next(value: $0) }
//        let output = try chained.parse(&input)
//        #expect(output == 14)
//    }
//
//    @Test
//    func `stored mappings preserve all three failure combinations`() {
//        let pure = Owned().map
//        let total = pure { $0 + 1 }
//        requireFailure(total, Never.self)
//
//        let fallible = Fallible().map
//        let preserved = fallible { $0 + 1 }
//        requireFailure(preserved, UpstreamFailure.self)
//
//        let pureThrowing = Owned().map
//        let transformed = pureThrowing { (_: consuming Int) throws(TransformFailure) -> Int in
//            throw .rejected
//        }
//        requireFailure(transformed, TransformFailure.self)
//
//        let both = Fallible().map
//        let combined = both { (_: consuming Int) throws(TransformFailure) -> Int in
//            throw .rejected
//        }
//        requireFailure(combined, Either<UpstreamFailure, TransformFailure>.self)
//    }
//
//    @Test
//    func `failure mapping works on an already mapped noncopyable parser`() {
//        let mapped = Owned().map { (_: consuming Int) throws(TransformFailure) -> Int in
//            throw .rejected
//        }
//        let parser = (consume mapped).map.failure { _ in UpstreamFailure.rejected }
//        requireFailure(parser, UpstreamFailure.self)
//        var input = 0
//        do throws(UpstreamFailure) {
//            _ = try parser.parse(&input)
//            Issue.record("Expected the transformed failure")
//        } catch {
//            #expect(error == .rejected)
//        }
//        #expect(input == 1)
//    }
//
//    @Test
//    func `an unused stored property destroys its owner exactly once`() {
//        let lifetime = Lifetime()
//        do {
//            let mapping = Owned(lifetime: lifetime).map
//            #expect(lifetime.destroyed == 0)
//            discard(mapping)
//            #expect(lifetime.destroyed == 1)
//        }
//        #expect(lifetime.destroyed == 1)
//        do {
//            let binding = Owned(lifetime: lifetime).flatMap
//            #expect(lifetime.destroyed == 1)
//            discard(binding)
//            #expect(lifetime.destroyed == 2)
//        }
//        #expect(lifetime.destroyed == 2)
//    }
//
//    @Test
//    func `failure property preserves scoped success lifetimes`() throws {
//        let values = [7, 8]
//        var input = ScopedInput(values.span)
//        let mapping = Scoped().map
//        let parser = mapping.failure { _ in TransformFailure.rejected }
//        let output = try parser.parse(&input)
//        #expect(output.values[0] == 7)
//        #expect(output.values[1] == 8)
//    }
//}
//
//private func discard<T: ~Copyable>(_ value: consuming T) {}
//private func requireFailure<P: Parsing & ~Copyable, E: Error>(_: borrowing P, _: E.Type)
//where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable, P.Failure == E {}
//
//private final class Lifetime { var destroyed = 0 }
//private struct Owned: Parsing, ~Copyable {
//    let lifetime: Lifetime?
//    init(lifetime: Lifetime? = nil) { self.lifetime = lifetime }
//    func parse(_ input: inout Int) -> Int { input += 1; return input }
//    deinit { lifetime?.destroyed += 1 }
//}
//private struct Next: Parsing, ~Copyable {
//    let value: Int
//    func parse(_ input: inout Int) -> Int { input += 10; return input + value }
//}
//private enum UpstreamFailure: Error { case rejected }
//private enum TransformFailure: Error { case rejected }
//private struct Fallible: Parsing, ~Copyable {
//    func parse(_ input: inout Int) throws(UpstreamFailure) -> Int { throw .rejected }
//}
//private struct ScopedInput: ~Copyable, ~Escapable {
//    let values: Span<Int>
//    @_lifetime(copy values)
//    init(_ values: Span<Int>) { self.values = values }
//}
//private struct ScopedOutput: ~Copyable, ~Escapable {
//    let values: Span<Int>
//    @_lifetime(copy values)
//    init(_ values: Span<Int>) { self.values = values }
//}
//private struct Scoped: Parsing, ~Copyable {
//    @_lifetime(&input)
//    func parse(_ input: inout ScopedInput) throws(UpstreamFailure) -> ScopedOutput {
//        ScopedOutput(input.values)
//    }
//}

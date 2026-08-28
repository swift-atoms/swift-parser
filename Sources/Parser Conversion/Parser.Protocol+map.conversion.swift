extension Parser.`Protocol` {

    @inlinable
    public func map<Downstream: Parser.Conversion.`Protocol`>(
        _ conversion: Downstream
    ) -> Parser.Converted<Self, Downstream>
    where Downstream.Input == Output {
        .init(upstream: self, downstream: conversion)
    }
}

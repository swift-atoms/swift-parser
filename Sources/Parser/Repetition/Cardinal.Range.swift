#if Repetition && Collection
    public import Cardinal
    public import Repetition

    extension Cardinal.Range {
        public func parser<
            Input: Swift::Collection
        >(
            for input: Input.Type
        ) -> Parser::Parser<
            Input,
            Input,
            Repetition<Self, Void>.Error
        >
        where Input.SubSequence == Input {
            Parser::Parser { input throws(Repetition<Self, Void>.Error) in
                let end = try self.end(in: input)
                let output = input[..<end]
                input = input[end..<input.endIndex]
                return output
            }
        }
    }
#endif

#if Repetition && Collection
    public import Cardinal
    public import Repetition
    public import Collection

    extension Cardinal.Range {
        public func parser<Input: Collection.Slice.`Protocol`>(forCollection input: Input.Type) -> Parser::Parser<Input, Input, Repetition<Self, Void>.Error>
        where Input.Element: ~Copyable {
            Parser::Parser { input throws(Repetition<Self, Void>.Error) in
                let end = try self.end(inCollection: input)
                let output = input[input.startIndex..<end]
                input = input[end..<input.endIndex]
                return output
            }
        }
    }
#endif

#if Repetition && Iterator
    public import Cardinal
    public import Repetition
    public import Iterator
    public import Either

    extension Cardinal.Range {
        public func parser<I: Iterating & ~Copyable & ~Escapable>(
            for input: Iterator::Iterator.Buffered<I, I.Failure>.Type
        ) -> Parser::Parser<Iterator::Iterator.Buffered<I, I.Failure>, [I.Element], Either<Repetition<Self, Void>.Error, I.Failure>>
        where I.Element: Copyable & Escapable {
            Parser::Parser { input throws(Either<Repetition<Self, Void>.Error, I.Failure>) in
                var output: [I.Element] = []
                try self.forEach(in: &input) { output.append($0) }
                return output
            }
        }
    }
#endif

#if Repetition
    public import Parser_Core
    public import Cardinal
    public import Repetition
    public import Either
    public import Checkpoint

    extension Cardinal.Range {
        public func parser<P: Parsing & ~Copyable, Rejection: Swift::Error, Fatal: Swift::Error>(
            _ build: () -> P
        ) -> Repetition<Self, P>.Parser<Rejection, Fatal>
        where
            P.Input: Restorable & ~Copyable & ~Escapable,
            P.Input.Checkpoint: Equatable,
            P.Output: Copyable & Escapable,
            P.Failure == Either<Rejection, Fatal>
        {
            .init(.init(self, operation: build()))
        }
        public func parser<Input: Restorable & ~Copyable & ~Escapable, P: Parsing & ~Copyable, Rejection: Swift::Error, Fatal: Swift::Error>(
            for input: Input.Type,
            @Builder<Input> _ build: () -> P
        ) -> Repetition<Self, P>.Parser<Rejection, Fatal>
        where
            Input.Checkpoint: Equatable,
            P.Input == Input,
            P.Input: ~Copyable & ~Escapable,
            P.Output: Copyable & Escapable,
            P.Failure == Either<Rejection, Fatal>
        {
            .init(.init(self, operation: build()))
        }
    }
#endif

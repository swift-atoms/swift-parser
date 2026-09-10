import Parser

extension User {
    struct Parser: Parsing {
        var body: some Parsing<Substring, User, Either<Rejected, Invalid>> {
            Parser::Parser(User.init) {
                Parser::Parser {
                    name
                    ","
                    age
                    "\n"
                }
                .mapFailure { _ in Rejected.record }
            }
        }

        private var name: some Parsing<Substring, String, Rejected> {
            text { $0.isLetter || $0 == " " }
        }

        private var age: some Parsing<Substring, String, Rejected> {
            text { $0 >= "0" && $0 <= "9" }
        }
    }
}

extension User.Parser {
    enum Rejected: Error { case record }
    enum Invalid: Error, Equatable { case age(String) }

    private func text(
        while accepts: @escaping (Character) -> Bool
    ) -> some Parsing<Substring, String, Rejected> {
        Repetition(
            (1...),
            operation: Predicate<Character> { accepts($0) }
        )
        .parser(for: Substring.self)
        .map { String($0) }
        .mapFailure { _ in Rejected.record }
    }
}

extension User {

    fileprivate init(name: String, age: String) throws(Parser.Invalid) {
        guard let value = Int(age), (0...130).contains(value) else {
            throw .age(age)
        }
        self.init(name: name, age: value)
    }
}

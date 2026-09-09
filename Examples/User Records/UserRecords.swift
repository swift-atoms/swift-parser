import Parser

/// Accepts zero or more records. A rejected record is restored and ends the batch.
struct UserRecords: Parsing {
    typealias Input = Substring
    typealias Output = [User]
    typealias Failure = Either<Repetition<PartialRangeFrom<Cardinal>, User.Parser>.Error, User.Parser.Invalid>
    
    var body: some Parsing<Substring, [User], Either<Repetition<PartialRangeFrom<Cardinal>, User.Parser>.Error, User.Parser.Invalid>> {
        (0...).parser { User.Parser() }
    }
}

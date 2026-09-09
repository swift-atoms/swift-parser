# User records

An executable example of importing a small text file into domain values. Its
executable and test targets live in `Examples/Examples.xcodeproj`, independently
of the library package manifest. The test target compiles the same model and
parser source files as the executable.

Open
`workspaces/parser.xcworkspace`, select **User Records Example**, choose **My Mac**,
and press **Cmd+R**. With no arguments it runs all three included samples, copied beside the executable. Press
**Cmd+U** to run the integration tests against the same parser implementation.

To read your own UTF-8 files, add their absolute paths under the scheme's
**Run → Arguments Passed On Launch**. Each file is parsed independently.

Start with `User.Parser.swift`: its `var body` composes name selection, a comma,
age selection, and a newline with the result builder, then maps the fields with `.map(User.init)`. The `name` and `age`
definitions are directly below the grammar. A local `text(while:)` helper and
explicit associated types below them bridge the current library API; these are
example-local scaffolding, not new public parser APIs. The throwing initializer
validates the age after the entire record has matched. `UserRecords.swift` repeats that complete parser using `0...` Cardinal
bounds. `UserRecordsExample.swift` handles files and displays results.

## Grammar

Each record is `name,age` followed by LF (`\n`). Names contain one or more Unicode
letters or spaces. Ages contain one or more ASCII decimal digits and must fit in
`Int` and be in `0...130`. Leading zeroes are accepted. Empty files are accepted.
This deliberately small format has no quoting, escaping, CRLF, or CSV dialect
support. The name rule illustrates a predicate; it is not a policy for personal
names in a production application.

## What to observe

- **complete.txt** returns Alice and Bob, with no remaining input.
- **rejected.txt** returns Alice and leaves the entire `Bob,not-an-age` record
  and Carol unread. Even though Bob's name and comma were consumed during the
  attempt, repetition restores that rejected iteration.
- **invalid-age.txt** throws the typed invalid-age error for Bob. Carol remains
  unread. Alice and Bob's input has been consumed, and no batch is returned.

An `Either` alone does not define recovery. Here the repetition API gives its
left branch the explicit meaning **rejected iteration** and its right branch
**fatal failure**. The record parser maps grammar mismatches to rejection and
age validation failures to fatal errors. A production importer could choose a
different policy, for example collecting invalid records as values.

A successful batch does not necessarily mean a complete file: always inspect
remaining input. This executable labels that situation as **Stopped**. A strict
importer should reject leftovers; an incremental reader could retain them and
append another chunk before retrying.

Restoration affects input, not external effects. These parsers only construct
values. Database writes and other effects belong after parsing and validation.

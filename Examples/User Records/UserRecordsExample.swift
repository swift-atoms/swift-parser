import Foundation
import Parser

@main
struct UserRecordsExample {
    static func main() throws {
        let paths = Array(CommandLine.arguments.dropFirst())
        let samples: [(String, String)]
        if paths.isEmpty {
            samples = try ["complete", "rejected", "invalid-age"].map { name in
                let url = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
                    .appendingPathComponent("Samples/\(name).txt")
                return (name, try String(contentsOf: url, encoding: .utf8))
            }
        } else {
            samples = try paths.map { ($0, try String(contentsOfFile: $0, encoding: .utf8)) }
        }

        for (name, text) in samples {
            print("\n--- \(name) ---")
            var input = text[...]
            do {
                let users = try UserRecords().parse(&input)
                for user in users { print("User(name: \(user.name.debugDescription), age: \(user.age))") }
                print(input.isEmpty ? "Complete: \(users.count) records" : "Stopped: \(users.count) records; next record rejected")
            } catch {
                switch error {
                case .left(let failure): print("Repetition failed: \(failure)")
                case .right(.age(let age)): print("Fatal: age \(age) must be an integer in 0...130")
                }
                print("No batch returned; earlier accepted input remains consumed.")
            }
            print("Remaining input: \(String(input).debugDescription)")
        }
    }
}

import Foundation

struct CharEntry {
    let char: String
    let pinyin: String
}

enum CSVHandler {
    static func read(from path: String) -> [CharEntry] {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Error: Cannot read \(path)")
            exit(1)
        }
        return content.components(separatedBy: "\n")
            .dropFirst()
            .compactMap { line -> CharEntry? in
                let parts = line.components(separatedBy: ",")
                guard parts.count >= 2 else { return nil }
                let char = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let pinyin = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                guard !char.isEmpty, !pinyin.isEmpty else { return nil }
                return CharEntry(char: char, pinyin: pinyin)
            }
    }

    static func write(results: [(char: String, pinyin: String, canType: Bool)], to path: String) {
        var lines = ["字符,拼音,原生可打出"]
        for r in results {
            let char = r.char.trimmingCharacters(in: .whitespacesAndNewlines)
            let pinyin = r.pinyin.trimmingCharacters(in: .whitespacesAndNewlines)
            lines.append("\(char),\(pinyin),\(r.canType)")
        }
        let content = lines.joined(separator: "\n")
        try? content.write(toFile: path, atomically: true, encoding: .utf8)
    }
}

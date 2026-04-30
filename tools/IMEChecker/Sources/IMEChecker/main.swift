import Foundation

// 解析命令行参数
let args = CommandLine.arguments
guard args.count >= 3 else {
    print("Usage: IMEChecker --input <csv> --output <csv>")
    print("Example: IMEChecker --input pinyin-data.csv --output results.csv")
    exit(1)
}

var inputPath = ""
var outputPath = ""
for i in 1..<args.count - 1 {
    if args[i] == "--input" { inputPath = args[i+1] }
    if args[i] == "--output" { outputPath = args[i+1] }
}

guard !inputPath.isEmpty, !outputPath.isEmpty else {
    print("Error: --input and --output are required")
    exit(1)
}

// 读取CSV
let entries = CSVHandler.read(from: inputPath)
print("Loaded \(entries.count) entries from \(inputPath)")

// 切换输入法
IMESwitch.switchToSimplifiedPinyin()
print("Switched to Simplified Pinyin input source")
Thread.sleep(forTimeInterval: 1.0)

// 逐个测试
var results: [(char: String, pinyin: String, canType: Bool)] = []
for (index, entry) in entries.enumerated() {
    let candidates = CandidateCapture.getCandidates(for: entry.pinyin)
    let canType = candidates.contains(entry.char)
    results.append((entry.char, entry.pinyin, canType))
    print("[\(index+1)/\(entries.count)] \(entry.char) (\(entry.pinyin)): \(canType ? "✅" : "❌")")
    Thread.sleep(forTimeInterval: 0.3)
}

// 写出CSV
CSVHandler.write(results: results, to: outputPath)
print("Done. Results saved to \(outputPath)")

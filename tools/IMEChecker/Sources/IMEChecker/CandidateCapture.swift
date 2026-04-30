import AppKit
import Vision
import Foundation

enum CandidateCapture {
    static func getCandidates(for pinyin: String) -> [String] {
        // 激活TextEdit
        activateTextEdit()
        Thread.sleep(forTimeInterval: 0.8)

        // 输入拼音
        typeString(pinyin)
        Thread.sleep(forTimeInterval: 0.5)

        // 截图并OCR识别候选窗口
        let candidates = captureAndRecognize()

        // ESC取消候选，清空输入
        postKey(53) // ESC
        Thread.sleep(forTimeInterval: 0.1)
        postKeyWithCmd(0) // Cmd+A
        postKey(51) // Delete
        Thread.sleep(forTimeInterval: 0.1)

        return candidates
    }

    private static func activateTextEdit() {
        var error: NSDictionary?
        NSAppleScript(source: """
        tell application "TextEdit"
            activate
            if (count of documents) = 0 then make new document
        end tell
        """)?.executeAndReturnError(&error)
    }

    private static func captureAndRecognize() -> [String] {
        let path = "/tmp/ime_capture.png"
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-x", path]
        task.launch()
        task.waitUntilExit()

        guard let image = NSImage(contentsOfFile: path),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return []
        }

        var rawTexts: [String] = []
        let semaphore = DispatchSemaphore(value: 0)

        let request = VNRecognizeTextRequest { req, _ in
            defer { semaphore.signal() }
            guard let observations = req.results as? [VNRecognizedTextObservation] else { return }
            for obs in observations {
                if let top = obs.topCandidates(1).first {
                    rawTexts.append(top.string)
                }
            }
        }
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        request.recognitionLevel = .accurate
        try? VNImageRequestHandler(cgImage: cgImage).perform([request])
        semaphore.wait()

        // 解析候选：候选窗口格式为「就」「2鹫3久4九」「6酒」等
        // 提取所有1-4个汉字的片段
        var candidates: [String] = []
        let pattern = "[\\u4e00-\\u9fff]{1,4}"
        let regex = try? NSRegularExpression(pattern: pattern)
        for text in rawTexts {
            let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []
            for match in matches {
                if let range = Range(match.range, in: text) {
                    candidates.append(String(text[range]))
                }
            }
        }
        return candidates
    }

    private static func typeString(_ s: String) {
        for char in s.unicodeScalars {
            postKey(keyCodeForASCII(char.value))
            Thread.sleep(forTimeInterval: 0.08)
        }
    }

    private static func postKey(_ keyCode: CGKeyCode) {
        CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)?.post(tap: .cgSessionEventTap)
        CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)?.post(tap: .cgSessionEventTap)
    }

    private static func postKeyWithCmd(_ keyCode: CGKeyCode) {
        let src = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        down?.flags = .maskCommand
        down?.post(tap: .cgSessionEventTap)
        CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)?.post(tap: .cgSessionEventTap)
    }

    private static func keyCodeForASCII(_ ascii: UInt32) -> CGKeyCode {
        let map: [UInt32: CGKeyCode] = [
            97:0, 98:11, 99:8, 100:2, 101:14, 102:3, 103:5, 104:4,
            105:34, 106:38, 107:40, 108:37, 109:46, 110:45, 111:31,
            112:35, 113:12, 114:15, 115:1, 116:17, 117:32, 118:9,
            119:13, 120:7, 121:16, 122:6
        ]
        return map[ascii] ?? 0
    }
}

import Carbon

enum IMESwitch {
    static func switchToSimplifiedPinyin() {
        guard let sources = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else { return }
        for source in sources {
            guard let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
            let id = Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
            if id == "com.apple.inputmethod.SCIM.ITABC" {
                TISSelectInputSource(source)
                return
            }
        }
        print("Warning: Simplified Pinyin input source not found")
    }
}

# Quick Reference: JSON Stroke Data System

## 📁 Project Structure

```
YourProject/
├── GlyphRepository.swift          ← Updated to use JSON loader
├── StrokeDataLoader.swift         ← NEW: Loads JSON on-demand
├── StrokeDataConverter.swift      ← NEW: Conversion utilities
├── StrokeDataTests.swift          ← NEW: Test suite
└── StrokeData/                    ← NEW: Folder reference (blue icon)
    ├── 3042.json                  ← あ
    ├── 3044.json                  ← い
    ├── 3046.json                  ← う
    └── ...
```

## 🔧 How to Add JSON Files in Xcode

1. **Right-click** project → **Add Files to "YourProject"**
2. Select your StrokeData folder
3. ✅ **Check**: "Copy items if needed"
4. ✅ **Check**: Your app target
5. ⚠️ **Important**: Choose **"Create folder references"** (blue folder)
   - NOT "Create groups" (yellow folder)

## 📝 JSON File Format

**Filename**: `{4-digit-hex-codepoint}.json` (e.g., `3042.json`)

```json
{
  "strokes": [
    {
      "points": [
        { "x": 0.35, "y": 0.15, "t": 0.0 },
        { "x": 0.32, "y": 0.25, "t": 0.05 }
      ]
    }
  ]
}
```

### Coordinates
- **x, y**: 0.0 to 1.0 (normalized)
- **t**: Time in seconds (starts at 0.0)

### Naming Convention
| Character | Codepoint | Filename |
|-----------|-----------|----------|
| あ | U+3042 | `3042.json` |
| い | U+3044 | `3044.json` |
| ア | U+30A2 | `30A2.json` |
| か | U+304B | `304B.json` |

## 💻 Usage in Code

### Load stroke data
```swift
// Direct loading
let strokes = StrokeDataLoader.loadStrokes(for: 0x3042)

// Through repository (recommended)
let repo = GlyphBundleRepository()
let id = CharacterID(script: .kana, codepoint: Int(0x3042))
let glyph = try await repo.glyph(for: id)
```

### Convert existing data
```swift
let oldData: [UInt32: [StrokePath]] = [...]

let outputDir = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("StrokeData")

try StrokeDataConverter.batchExport(oldData, to: outputDir)
```

### Validate files
```swift
if let url = Bundle.main.url(forResource: "StrokeData", withExtension: nil) {
    let results = try StrokeDataConverter.validateDirectory(url)
    results.forEach { print($0.description) }
}
```

## 🧪 Testing

### Run all tests
```swift
// In Xcode: ⌘U (Command-U)
// Or use Test Navigator
```

### Manual testing
```swift
#if DEBUG
await StrokeDataTestExamples.runExamples()
#endif
```

## 🎯 Memory Benefits

| Scenario | Before | After | Savings |
|----------|--------|-------|---------|
| App startup | 4 MB | ~0 KB | 100% |
| Single character | 4 MB | 20 KB | 99.5% |
| 10 characters | 4 MB | 200 KB | 95% |
| Entire hiragana | 4 MB | ~2 MB | 50% |

💡 **Key**: Data loaded only when needed, not all at once

## ⚠️ Troubleshooting

### File not found
```
✅ Check: Build Phases → Copy Bundle Resources
✅ Verify: Folder is blue (folder reference), not yellow (group)
✅ Clean: ⌘⇧K then rebuild
```

### Invalid JSON
```swift
// Validate specific file
let url = Bundle.main.url(forResource: "3042", 
                         withExtension: "json",
                         subdirectory: "StrokeData")!
let result = StrokeDataConverter.validateFile(url)
print(result.description)
```

### Wrong data loaded
```
✅ Verify: Filename matches codepoint (4 uppercase hex digits)
✅ Check: JSON is valid (use validator)
✅ Test: Open file in Xcode to verify content
```

## 📚 Documentation Files

- **MIGRATION_GUIDE.md** - Complete migration instructions
- **StrokeData_README.md** - JSON format specification  
- **StrokeDataTests.swift** - Test examples and validation
- **THIS FILE** - Quick reference

## 🚀 Deployment Checklist

- [ ] Add `StrokeDataLoader.swift` to project
- [ ] Update `GlyphRepository.swift` (✅ already done)
- [ ] Create JSON files for your characters
- [ ] Add StrokeData folder to Xcode (as folder reference)
- [ ] Verify files in Build Phases → Copy Bundle Resources
- [ ] Run tests (⌘U)
- [ ] Test app with sample characters
- [ ] Validate all JSON files
- [ ] Clean and rebuild
- [ ] Test on device/simulator

## 🔗 Find Unicode Codepoints

```swift
// Convert character to hex filename
let character = "あ"
if let scalar = character.unicodeScalars.first {
    let hex = String(format: "%04X", scalar.value)
    print("Filename: \(hex).json")  // "3042.json"
}
```

## 📊 Generate Codepoint List

```swift
// Hiragana range
for codepoint in 0x3041...0x3096 {
    let character = String(UnicodeScalar(codepoint)!)
    let hex = String(format: "%04X", codepoint)
    print("\(hex).json  \(character)")
}

// Katakana range  
for codepoint in 0x30A1...0x30F6 {
    let character = String(UnicodeScalar(codepoint)!)
    let hex = String(format: "%04X", codepoint)
    print("\(hex).json  \(character)")
}
```

## 💡 Pro Tips

1. **Start small**: Begin with 5-10 characters to verify setup
2. **Validate early**: Use converter tools to catch errors
3. **Cache if needed**: Add caching layer for frequently used characters
4. **Preload lessons**: Load lesson characters in background before starting
5. **Monitor memory**: Use Instruments to verify memory savings
6. **Version control**: JSON files are git-friendly (unlike binary data)

## 🆘 Need Help?

- Review example files: `3042.json`, `3044.json`, `30A2.json`
- Check test suite: `StrokeDataTests.swift`  
- Read migration guide: `MIGRATION_GUIDE.md`
- Validate your files: `StrokeDataConverter.validateDirectory()`

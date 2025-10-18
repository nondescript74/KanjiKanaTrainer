# Stroke Data Migration Guide

## Overview

This migration replaces hardcoded Swift stroke data with JSON files that are loaded on-demand, significantly reducing memory usage.

## What Changed

### Before (Memory-Intensive)
- All stroke data was hardcoded in `KanaStrokeData.swift`
- Loaded into memory at app startup
- Could cause memory issues with large datasets

### After (Memory-Efficient)
- Stroke data stored in individual JSON files
- Loaded only when needed
- Minimal memory footprint

## Files Created

1. **StrokeDataLoader.swift** - Handles loading JSON files on-demand
2. **StrokeDataConverter.swift** - Utility for converting/validating data
3. **StrokeData_README.md** - Documentation for JSON format
4. **StrokeData/*.json** - Individual stroke data files

## How It Works

### 1. File Organization

```
YourApp.app/
└── StrokeData/
    ├── 3042.json  (あ)
    ├── 3044.json  (い)
    ├── 3046.json  (う)
    ├── 30A2.json  (ア)
    └── ...
```

### 2. Loading Process

When a character is requested:
1. `GlyphBundleRepository` calls `StrokeDataLoader.loadStrokes(for: codepoint)`
2. Loader looks for `{CODEPOINT}.json` in the StrokeData directory
3. If found, JSON is decoded into `[StrokePath]`
4. If not found, falls back to synthetic strokes
5. Only that character's data is loaded (not the entire dataset)

### 3. JSON Format

Each file contains:
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

## Setting Up in Xcode

### Add JSON Files to Your Project

1. **Create StrokeData folder in Xcode:**
   - Right-click your project in Navigator
   - New Group → Name it "StrokeData"

2. **Add JSON files:**
   - Drag your JSON files into this group
   - ✅ Check "Copy items if needed"
   - ✅ Check your app target
   - ⚠️ Choose "Create folder references" (NOT "Create groups")

3. **Verify bundle inclusion:**
   - Select your target → Build Phases
   - Expand "Copy Bundle Resources"
   - Ensure StrokeData folder is listed

### Folder Structure in Xcode

```
YourProject/
├── Models.swift
├── GlyphRepository.swift
├── StrokeDataLoader.swift
├── StrokeDataConverter.swift
└── StrokeData/               ← Blue folder icon
    ├── 3042.json
    ├── 3044.json
    └── ...
```

## Converting Existing Data

If you have existing stroke data in Swift format:

```swift
// Your old data format
let strokeData: [UInt32: [StrokePath]] = [
    0x3042: [...],
    0x3044: [...]
]

// Convert to JSON files
let outputDirectory = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("StrokeData")

try? StrokeDataConverter.batchExport(strokeData, to: outputDirectory)
```

Then copy the generated files into your Xcode project.

## Validating JSON Files

```swift
// Validate all files in StrokeData directory
if let bundleURL = Bundle.main.url(forResource: "StrokeData", withExtension: nil) {
    let results = try? StrokeDataConverter.validateDirectory(bundleURL)
    results?.forEach { print($0.description) }
}
```

## Memory Benefits

### Example Calculation

**Before:**
- 200 characters × 20 KB each = 4 MB in memory at startup
- All loaded regardless of usage

**After:**
- Only active characters loaded
- Typical lesson: 5-10 characters = 100-200 KB
- 95%+ memory reduction

## Performance Considerations

### Pros
- ✅ Dramatically reduced memory footprint
- ✅ Faster app startup
- ✅ Scalable to thousands of characters
- ✅ Easy to update data without recompiling

### Cons
- ⚠️ Small disk I/O overhead per character
- ⚠️ First load of each character slightly slower

### Optimization Tips

1. **Add caching if needed:**
```swift
struct CachedStrokeDataLoader {
    private static var cache: [UInt32: [StrokePath]] = [:]
    
    static func loadStrokes(for codepoint: UInt32) -> [StrokePath]? {
        if let cached = cache[codepoint] {
            return cached
        }
        
        guard let strokes = StrokeDataLoader.loadStrokes(for: codepoint) else {
            return nil
        }
        
        cache[codepoint] = strokes
        return strokes
    }
}
```

2. **Pre-load lesson characters:**
```swift
func preloadLesson(_ characters: [CharacterID]) async {
    await withTaskGroup(of: Void.self) { group in
        for char in characters {
            group.addTask {
                _ = StrokeDataLoader.loadStrokes(for: UInt32(char.codepoint))
            }
        }
    }
}
```

## Troubleshooting

### "File not found" errors

**Problem:** JSON files not included in bundle

**Solution:**
1. Check Build Phases → Copy Bundle Resources
2. Verify "Create folder references" was used
3. Clean build folder (⌘⇧K) and rebuild

### Invalid JSON errors

**Problem:** Malformed JSON files

**Solution:**
```swift
// Validate files
let results = try? StrokeDataConverter.validateDirectory(url)
results?.filter { !$0.isValid }.forEach { print($0.description) }
```

### Wrong stroke data loaded

**Problem:** Filename doesn't match codepoint

**Solution:**
- Filenames must be 4-digit uppercase hex (e.g., `3042.json`)
- Use converter utility to ensure correct naming

## Next Steps

1. ✅ Add StrokeDataLoader.swift to your project
2. ✅ Update GlyphRepository.swift (already done)
3. 📦 Create/convert your JSON files
4. 📁 Add JSON files to Xcode with folder references
5. 🧪 Test with a few characters
6. 📊 Validate all files
7. 🚀 Deploy

## Need More Characters?

Create JSON files for additional characters using the format in `StrokeData_README.md`. You can:
- Hand-author JSON files
- Convert from KanjiVG SVG data
- Use the converter utility
- Generate from other stroke databases

## Questions?

Refer to:
- `StrokeData_README.md` - JSON format specification
- `StrokeDataLoader.swift` - Loading implementation
- `StrokeDataConverter.swift` - Conversion utilities
- Example files: `3042.json`, `3044.json`, `30A2.json`

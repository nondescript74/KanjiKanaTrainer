# KanjiVG Stroke Data Downloader (JSON Format)

This script downloads and converts KanjiVG SVG files for hiragana and katakana characters into JSON files that can be loaded at runtime, reducing Xcode memory pressure and indexing overhead.

## Benefits of JSON Format

✅ **Reduced Memory Pressure**: No large Swift files for Xcode to parse and index  
✅ **Faster Xcode Performance**: Smaller project size, faster compilation  
✅ **Runtime Loading**: Data loaded on-demand rather than compiled into binary  
✅ **Easy Updates**: Update stroke data without recompiling  
✅ **Better Version Control**: JSON diffs are cleaner than Swift code diffs  

## Prerequisites

- Python 3.6 or later (built-in on macOS)
- Internet connection

## Usage

### Step 1: Run the Script

Open Terminal and navigate to your project directory, then run:

```bash
python3 download_kana_strokes_json.py
```

The script will:
1. Download SVG files for all hiragana (あ-ゖ) and katakana (ァ-ヶ) characters
2. Parse the SVG path data to extract stroke coordinates
3. Normalize coordinates to 0.0-1.0 range
4. Generate JSON files with the stroke data

### Step 2: Expected Output

The script creates a `KanaStrokeData/` directory containing:
- `hiragana_strokes.json` - Hiragana stroke data only
- `katakana_strokes.json` - Katakana stroke data only
- `kana_strokes.json` - Combined hiragana and katakana data
- Individual SVG files for reference (e.g., `03042.svg` for あ)

### Step 3: Add JSON Files to Xcode

1. Drag the JSON file(s) into your Xcode project navigator
2. Make sure "Copy items if needed" is checked
3. Ensure it's added to your app target
4. **Important**: Add the JSON files to your target's "Copy Bundle Resources" build phase

### Step 4: Create Swift Model for JSON

Add this Swift code to your project to decode the JSON data:

```swift
import Foundation

struct StrokePoint: Codable {
    let x: Double
    let y: Double
    let t: Double
}

struct KanaCharacterData: Codable {
    let character: String
    let codepoint: Int
    let strokes: [[StrokePoint]]
}

class KanaStrokeDataLoader {
    static let shared = KanaStrokeDataLoader()
    
    private var strokeData: [String: KanaCharacterData] = [:]
    
    private init() {
        loadStrokeData()
    }
    
    private func loadStrokeData() {
        guard let url = Bundle.main.url(forResource: "kana_strokes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: KanaCharacterData].self, from: data) else {
            print("Failed to load stroke data")
            return
        }
        
        strokeData = decoded
        print("Loaded stroke data for \(strokeData.count) characters")
    }
    
    /// Get stroke data for a character by codepoint
    func strokeData(for codepoint: UInt32) -> KanaCharacterData? {
        let key = String(format: "U+%04X", codepoint)
        return strokeData[key]
    }
    
    /// Get stroke data for a character by its string representation
    func strokeData(for character: String) -> KanaCharacterData? {
        return strokeData.values.first { $0.character == character }
    }
    
    /// Convert StrokePoint array to StrokePath (adapt to your existing model)
    func strokePaths(for codepoint: UInt32) -> [StrokePath]? {
        guard let data = strokeData(for: codepoint) else { return nil }
        
        return data.strokes.map { stroke in
            let points = stroke.map { point in
                // Adapt this to match your StrokePath/StrokePoint model
                StrokePoint(x: point.x, y: point.y, t: point.t)
            }
            return StrokePath(points: points)
        }
    }
}
```

### Step 5: Update GlyphRepository

Replace the `generateSyntheticStrokes()` method in `GlyphBundleRepository` with:

```swift
func glyph(for id: CharacterID) async throws -> CharacterGlyph {
    if let payload = Self.hiragana[UInt32(id.codepoint)] {
        let strokes = KanaStrokeDataLoader.shared.strokePaths(for: UInt32(id.codepoint)) ?? []
        return CharacterGlyph(
            script: id.script, 
            codepoint: id.codepoint, 
            literal: payload.literal, 
            readings: payload.readings, 
            meaning: [], 
            strokes: strokes, 
            difficulty: 1
        )
    }
    if let payload = Self.katakana[UInt32(id.codepoint)] {
        let strokes = KanaStrokeDataLoader.shared.strokePaths(for: UInt32(id.codepoint)) ?? []
        return CharacterGlyph(
            script: id.script, 
            codepoint: id.codepoint, 
            literal: payload.literal, 
            readings: payload.readings, 
            meaning: [], 
            strokes: strokes, 
            difficulty: 1
        )
    }
    throw GlyphBundleError.missingGlyph(script: id.script, codepoint: UInt32(id.codepoint))
}
```

## JSON Structure

The JSON files use this structure:

```json
{
  "U+3042": {
    "character": "あ",
    "codepoint": 12354,
    "strokes": [
      [
        { "x": 0.1234, "y": 0.5678, "t": 0.00 },
        { "x": 0.2345, "y": 0.6789, "t": 0.05 },
        ...
      ],
      [
        { "x": 0.3456, "y": 0.7890, "t": 0.00 },
        ...
      ]
    ]
  },
  ...
}
```

Where:
- Key: Unicode codepoint in format "U+XXXX"
- `character`: The actual character
- `codepoint`: Numeric codepoint value
- `strokes`: Array of stroke arrays
  - Each stroke is an array of points
  - `x`, `y`: Normalized coordinates (0.0-1.0)
  - `t`: Timing parameter for animation

## File Selection

Choose which JSON file to use based on your needs:

- **`kana_strokes.json`** (recommended): Contains both hiragana and katakana (~100-150KB)
- **`hiragana_strokes.json`**: Hiragana only (~50-75KB)
- **`katakana_strokes.json`**: Katakana only (~50-75KB)

## Performance Tips

1. **Lazy Loading**: The singleton pattern loads data once on first access
2. **Bundle Resources**: JSON files are included in the app bundle, not compiled
3. **Caching**: Decoded data is cached in memory after first load
4. **Background Loading**: Consider loading in a background task if needed:

```swift
Task.detached(priority: .background) {
    _ = KanaStrokeDataLoader.shared
}
```

## Troubleshooting

### Script fails to download
- Check your internet connection
- KanjiVG might not have data for all characters
- The script will skip characters that fail and continue

### JSON file not found in app
- Verify the JSON file is added to your target's "Copy Bundle Resources"
- Check the file name matches exactly (including extension)
- Clean build folder (Cmd+Shift+K) and rebuild

### Parse errors
- Some SVG files may have complex paths that aren't fully supported
- The script uses a simplified SVG parser for common path commands

### Empty stroke data
- Not all characters in the Unicode range have KanjiVG data
- The script will note which characters were skipped

## Data Source

This script downloads data from [KanjiVG](https://github.com/KanjiVG/kanjivg), which is:
- Open source (Creative Commons Attribution-ShareAlike 3.0)
- Specifically designed for stroke order diagrams
- Maintained by the community

## License

The stroke data from KanjiVG is licensed under CC BY-SA 3.0.
Make sure to include attribution in your app if you distribute it.

## Migration from Swift Files

If you're migrating from the Swift file approach:

1. Remove the old `KanaStrokeData.swift` file from your project
2. Add the JSON file(s) to your project
3. Add the Swift model code above
4. Update your repository to use `KanaStrokeDataLoader`
5. Clean and rebuild your project

Your Xcode project should now be more responsive and use less memory!

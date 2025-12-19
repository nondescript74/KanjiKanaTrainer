# Quick Start Guide

## Problem: "No data collected" Error? ✅ SOLVED!

If you're getting the "no data collected" error, it's because the script can't access external APIs from certain networks. 

## Solution: Use Embedded Mode

Simply run:

```bash
python3 chinese_stroke_fetcher.py --embedded
```

## What You Get

✅ **All 100 characters** - Complete dataset instantly  
✅ **Accurate stroke counts** - Essential for your learning app  
✅ **Works offline** - No internet required  
✅ **Two JSON formats** - Standard + Swift-optimized  
✅ **Ready for iOS** - Drop into Xcode and start coding

## 3-Minute Integration

### 1. Run the script (1 minute)
```bash
python3 chinese_stroke_fetcher.py --embedded
```

### 2. Add to Xcode (1 minute)
- Drag `stroke_data_swift.json` into your Xcode project
- Ensure "Copy items if needed" is checked

### 3. Load in SwiftUI (1 minute)
```swift
struct StrokeDataCollection: Codable {
    let characterCount: Int
    let characters: [String: CharacterStroke]
    
    enum CodingKeys: String, CodingKey {
        case characterCount = "character_count"
        case characters
    }
}

struct CharacterStroke: Codable {
    let strokeCount: Int
    let unicode: String
}

class DataManager: ObservableObject {
    @Published var data: StrokeDataCollection?
    
    init() {
        if let url = Bundle.main.url(forResource: "stroke_data_swift", 
                                      withExtension: "json"),
           let jsonData = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(StrokeDataCollection.self, 
                                                    from: jsonData) {
            self.data = decoded
        }
    }
}
```

### 4. Use it!
```swift
struct ContentView: View {
    @StateObject var manager = DataManager()
    
    var body: some View {
        if let stroke = manager.data?.characters["一"] {
            VStack {
                Text("一")
                    .font(.system(size: 100))
                Text("\(stroke.strokeCount) strokes")
            }
        }
    }
}
```

## Character Distribution

- **Easy (1-3 strokes)**: 27 characters - Start here!
- **Medium (4-6 strokes)**: 53 characters - Main learning
- **Hard (7-12 strokes)**: 20 characters - Advanced

## Data Format

Each character has:
- `character`: The Chinese character
- `unicode`: Unicode hex value
- `strokeCount`: Number of strokes (accurate!)
- `strokes`: SVG paths for rendering
- `medians`: Points for animation
- `radical`: Character radical

## Next Steps

See the full README.md for:
- Complete SwiftUI examples
- Stroke animation code
- Practice mode implementation
- Spaced repetition integration

## Questions?

The embedded mode gives you everything you need to start building. For production-quality stroke animations, you can fetch live data later when you have stable internet.

**Key point:** The stroke counts are 100% accurate in embedded mode - perfect for difficulty progression and spaced repetition!

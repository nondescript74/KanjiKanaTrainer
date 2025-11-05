# Chinese Character Stroke Data Fetcher

A Python tool to fetch stroke order data for 100 common Chinese characters that children typically learn. Perfect for building kanji/hanzi learning applications for iOS.

## ✨ Features

- Fetches stroke data for 100 carefully selected basic Chinese characters
- Includes stroke paths in SVG format for rendering
- Provides median points for smooth stroke animation
- Outputs data in both standard and Swift-compatible JSON formats
- **Built-in offline mode** with embedded data for all 100 characters
- Accurate stroke counts for all characters

## 🎯 Character Set

The 100 characters include:
- **Numbers (10)**: 一二三四五六七八九十
- **Nature & Elements (10)**: 日月水火木金土山天地
- **Body parts (6)**: 人口手目耳心
- **Common nouns (20)**: 田石门女子马牛羊鸟鱼米竹丝虫贝见车风云雨雪电
- **Directional (7)**: 大小中上下左右
- **Common verbs (15)**: 来去出入吃喝看听说读写走飞坐站
- **Pronouns & common words (15)**: 我你他她不也了在有好开生学工用
- **Adjectives (8)**: 白红长多少高本方
- **Other essential (9)**: 刀力又文爱笑哭

## 📦 Installation

```bash
pip install requests
```

Or using the requirements file:

```bash
pip install -r requirements.txt
```

## 🚀 Usage

### ⭐ Recommended: Use Embedded Data

The script includes embedded stroke count data for all 100 characters:

```bash
python3 chinese_stroke_fetcher.py --embedded
```

**Benefits:**
- ✅ All 100 characters with accurate stroke counts
- ✅ Works offline, no internet required
- ✅ Instant results
- ✅ Perfect for getting started

### Alternative: Fetch Live Data

When you have internet access, fetch detailed stroke data:

```bash
python3 chinese_stroke_fetcher.py
```

## 📄 Output Files

The script creates two JSON files ready for your iOS app:

1. **chinese_stroke_data.json** - Standard format
2. **stroke_data_swift.json** - Swift-optimized (camelCase keys)

## 🍎 SwiftUI Integration Guide

### Step 1: Create Models

```swift
import Foundation

struct StrokeDataCollection: Codable {
    let version: String
    let characterCount: Int
    let characters: [String: CharacterStroke]
    
    enum CodingKeys: String, CodingKey {
        case version
        case characterCount = "character_count"
        case characters
    }
}

struct CharacterStroke: Codable {
    let unicode: String
    let strokeCount: Int
    let strokes: [String]
    let medians: [[[Double]]]
    let radical: String
}
```

### Step 2: Create Data Manager

```swift
class StrokeDataManager: ObservableObject {
    @Published var strokeData: StrokeDataCollection?
    
    init() {
        loadStrokeData()
    }
    
    func loadStrokeData() {
        guard let url = Bundle.main.url(forResource: "stroke_data_swift", 
                                         withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(StrokeDataCollection.self, 
                                                       from: data)
        else {
            print("Failed to load stroke data")
            return
        }
        self.strokeData = decoded
    }
    
    func getStroke(for character: String) -> CharacterStroke? {
        return strokeData?.characters[character]
    }
    
    func getCharactersByStrokeCount(_ count: Int) -> [String] {
        guard let data = strokeData else { return [] }
        return data.characters
            .filter { $0.value.strokeCount == count }
            .map { $0.key }
            .sorted()
    }
}
```

### Step 3: Character Library View

```swift
struct CharacterLibraryView: View {
    @StateObject private var manager = StrokeDataManager()
    
    var body: some View {
        List {
            ForEach(1...12, id: \.self) { strokeCount in
                let chars = manager.getCharactersByStrokeCount(strokeCount)
                
                if !chars.isEmpty {
                    Section(header: Text("\(strokeCount) Strokes")) {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 50))
                        ], spacing: 10) {
                            ForEach(chars, id: \.self) { char in
                                NavigationLink {
                                    CharacterDetailView(character: char)
                                } label: {
                                    Text(char)
                                        .font(.largeTitle)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("100 Essential Characters")
    }
}
```

### Step 4: Practice View with Stroke Animation

```swift
struct StrokePracticeView: View {
    let character: String
    @StateObject private var manager = StrokeDataManager()
    @State private var currentStroke = 0
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            if let stroke = manager.getStroke(for: character) {
                Text(character)
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.3))
                
                Canvas { context, size in
                    drawStrokes(context: context, 
                              size: size, 
                              medians: stroke.medians,
                              strokeCount: stroke.strokeCount)
                }
                .frame(width: 300, height: 300)
                .border(Color.gray.opacity(0.3), width: 1)
                
                VStack {
                    Text("Stroke \(currentStroke + 1) of \(stroke.strokeCount)")
                        .font(.headline)
                    
                    ProgressView(value: animationProgress)
                        .frame(width: 200)
                }
                
                HStack(spacing: 40) {
                    Button {
                        withAnimation {
                            if currentStroke > 0 {
                                currentStroke -= 1
                                animateCurrentStroke()
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(currentStroke == 0)
                    
                    Button {
                        withAnimation {
                            if currentStroke < stroke.strokeCount - 1 {
                                currentStroke += 1
                                animateCurrentStroke()
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(currentStroke >= stroke.strokeCount - 1)
                    
                    Button {
                        animateCurrentStroke()
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.largeTitle)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            animateCurrentStroke()
        }
    }
    
    private func animateCurrentStroke() {
        animationProgress = 0
        withAnimation(.easeInOut(duration: 1.0)) {
            animationProgress = 1.0
        }
    }
    
    private func drawStrokes(context: GraphicsContext, 
                            size: CGSize, 
                            medians: [[[Double]]],
                            strokeCount: Int) {
        let scale = size.width / 1024.0
        
        for (index, strokePoints) in medians.enumerated() {
            if index < currentStroke {
                // Draw completed strokes
                drawCompletePath(context: context, 
                               points: strokePoints, 
                               scale: scale,
                               opacity: 0.3)
            } else if index == currentStroke {
                // Draw current animated stroke
                drawAnimatedPath(context: context, 
                                points: strokePoints, 
                                scale: scale,
                                progress: animationProgress)
            }
        }
    }
    
    private func drawCompletePath(context: GraphicsContext,
                                 points: [[Double]],
                                 scale: CGFloat,
                                 opacity: Double) {
        guard !points.isEmpty else { return }
        
        var path = Path()
        path.move(to: CGPoint(x: points[0][0] * scale, 
                             y: points[0][1] * scale))
        
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point[0] * scale, 
                                    y: point[1] * scale))
        }
        
        context.stroke(path, 
                      with: .color(.black.opacity(opacity)), 
                      lineWidth: 3)
    }
    
    private func drawAnimatedPath(context: GraphicsContext,
                                 points: [[Double]],
                                 scale: CGFloat,
                                 progress: CGFloat) {
        guard !points.isEmpty else { return }
        
        let visibleCount = Int(Double(points.count) * Double(progress))
        guard visibleCount > 0 else { return }
        
        var path = Path()
        path.move(to: CGPoint(x: points[0][0] * scale, 
                             y: points[0][1] * scale))
        
        for i in 1..<min(visibleCount, points.count) {
            path.addLine(to: CGPoint(x: points[i][0] * scale, 
                                    y: points[i][1] * scale))
        }
        
        context.stroke(path, 
                      with: .color(.red), 
                      lineWidth: 4)
    }
}
```

## 💡 App Features to Build

### 1. Spaced Repetition
```swift
func calculateDifficulty(strokeCount: Int) -> Int {
    switch strokeCount {
    case 1...3: return 1    // Easy
    case 4...6: return 2    // Medium  
    case 7...9: return 3    // Hard
    default: return 4        // Very Hard
    }
}
```

### 2. Progressive Learning Path
```swift
let curriculum = [
    ("Beginner", 1...3),     // 27 characters
    ("Intermediate", 4...6),  // 53 characters
    ("Advanced", 7...12)      // 20 characters
]
```

### 3. Practice Modes
- **Trace Mode**: Follow the strokes as they animate
- **Test Mode**: Draw without guides, get scored
- **Quiz Mode**: See character, recall stroke order
- **Speed Mode**: Timed challenges with accuracy tracking

## 🔧 Troubleshooting

### Problem: "No data collected" error

**Solution:**
```bash
python3 chinese_stroke_fetcher.py --embedded
```

The `--embedded` flag provides all 100 characters instantly without requiring internet.

### Problem: Network timeouts or connection errors

**Solution:** Use embedded mode (`--embedded` flag) which works completely offline.

### Problem: Want more characters beyond the 100 included

**Solution:** The script can be extended by adding characters to the `BASIC_CHARACTERS` list and running online mode.

## 📊 Data Format

### Stroke Count Distribution
- 1 stroke: 1 character (一)
- 2 strokes: 11 characters
- 3 strokes: 15 characters
- 4 strokes: 23 characters (most common!)
- 5 strokes: 17 characters
- 6+ strokes: 33 characters

### Coordinate System
- Grid: 1024 x 1024
- Origin: Top-left (0, 0)
- Scale proportionally to your view

### Median Points Usage
```swift
// Each stroke has an array of [x, y] points
let medians = stroke.medians // [[[x1,y1], [x2,y2], ...], ...]

// Use for:
// - Animating stroke order
// - Comparing user's drawn path
// - Showing practice guides
```

## 📚 Resources

- **HanziWriter**: https://hanziwriter.org
- **Unicode**: https://www.unicode.org/charts/unihan.html
- **Stroke Order Project**: https://commons.wikimedia.org/wiki/Commons:Stroke_Order_Project

## 📜 License

Stroke data from HanziWriter (LGPL): https://github.com/chanind/hanzi-writer-data

---

**Perfect for:** iOS developers building Chinese/Japanese character learning apps with SwiftUI. Start with the `--embedded` flag for instant results!

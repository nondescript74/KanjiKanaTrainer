# Quick Start: Adding Chinese Numbers

## What You're Getting

Your app now supports **Chinese numbers 0-10** with proper stroke order from KanjiVG.

### Character List:
```
〇 (0)  líng   - 1 stroke
一 (1)  yī     - 1 stroke  
二 (2)  èr     - 2 strokes
三 (3)  sān    - 3 strokes
四 (4)  sì     - 5 strokes
五 (5)  wǔ     - 4 strokes
六 (6)  liù    - 4 strokes
七 (7)  qī     - 2 strokes
八 (8)  bā     - 2 strokes
九 (9)  jiǔ    - 2 strokes
十 (10) shí    - 2 strokes
```

## 3-Step Setup

### Step 1: Download Stroke Data
```bash
python3 download_chinese_numbers.py
```
**Output**: `strokedata/chinesenumbers.json`

### Step 2: Add to Xcode
1. Drag `chinesenumbers.json` into project
2. Check "Copy items if needed"
3. Select your app target

### Step 3: Add Swift File
1. Add `ChineseStrokeDataLoader.swift` to project
2. Ensure it's in your app target

## Test It!

1. **Build** (⌘B)
2. **Run** (⌘R)
3. **Select** "Chinese Numbers" in the picker
4. **Try** "Lesson Demo" or "Practice Random Character"

## What You'll See

### Main Screen:
```
┌─────────────────────────────────────┐
│      KanjiKana Trainer             │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────┬─────────┬──────────┐  │
│  │Hiragana │Katakana │Chinese #s│  │ ← Segmented Picker
│  └─────────┴─────────┴──────────┘  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │     Lesson Demo            │   │ ← Primary Button
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Practice Random Character  │   │ ← Secondary Button
│  └─────────────────────────────┘   │
│                                     │
│             Version 1.0 (1)        │ ← New!
└─────────────────────────────────────┘
```

### Lesson Demo View (Chinese):
```
┌─────────────────────────────────────┐
│         ← Lesson Demo              │
├─────────────────────────────────────┤
│                                     │
│              二                     │ ← Large character
│         (èr / ji6)                  │ ← Pinyin / Jyutping
│             two                     │ ← English meaning
│                                     │
│    ┌─────────────────────────┐     │
│    │                         │     │
│    │   Stroke animation      │     │ ← Stroke display
│    │                         │     │
│    └─────────────────────────┘     │
│                                     │
│  [Next Stroke] [Auto Play]         │ ← Controls
│                                     │
└─────────────────────────────────────┘
```

### Practice View (Chinese):
```
┌─────────────────────────────────────┐
│         ← Practice                  │
├─────────────────────────────────────┤
│                                     │
│              五                     │ ← Character to write
│         (wǔ / ng5)                  │ ← Pronunciations
│            five                     │ ← Meaning
│                                     │
│    ┌─────────────────────────┐     │
│    │                         │     │
│    │   Drawing canvas        │     │ ← User draws here
│    │                         │     │
│    └─────────────────────────┘     │
│                                     │
│  [Clear]           [Evaluate]      │ ← Actions
│                                     │
│         Score: 92%                  │ ← Feedback
│                                     │
└─────────────────────────────────────┘
```

## File Structure

```
YourProject/
├── KanjiKanaTrainerApp.swift         (unchanged)
├── RootView.swift                     (✏️ modified)
├── Models.swift                       (✅ already had .hanzi!)
├── GlyphRepository.swift              (✏️ modified)
├── StrokeDataLoader.swift            (unchanged)
├── ChineseStrokeDataLoader.swift     (⭐ NEW)
├── LessonView.swift                  (unchanged)
├── PracticeView.swift                (unchanged)
│
├── strokedata/
│   ├── kanastrokes.json              (existing)
│   └── chinesenumbers.json           (⭐ NEW)
│
├── download_kana_strokes_json_fixed.py  (existing)
├── download_chinese_numbers.py       (⭐ NEW)
│
├── CHINESE_SETUP.md                  (⭐ NEW - full guide)
├── CHINESE_NUMBERS_REFERENCE.md      (⭐ NEW - number reference)
└── IMPLEMENTATION_SUMMARY.md         (⭐ NEW - this summary)
```

## Code Changes Summary

### Models.swift
No changes needed! Already had:
```swift
enum Script: String, Codable { 
    case kana, kanji, hanzi  // ← hanzi already there!
}
```

### GlyphRepository.swift
Added Chinese number data:
```swift
private static let hanzi: [UInt32: ...] = {
    // 0-10 plus bonus characters
    (0x4E00, "一", ["yī", "ji1"], ["one"]),
    // ... etc
}
```

### RootView.swift
Added third option:
```swift
enum KanaScript: String, CaseIterable {
    case hiragana = "Hiragana"
    case katakana = "Katakana"
    case chineseNumbers = "Chinese Numbers"  // ← NEW!
}
```

## Debug Output

When running, you'll see console messages:

```
✅ Loaded stroke data for 46 characters  ← Kana
✅ Found chinesenumbers.json at: ...     ← Chinese
✅ Loaded stroke data for 14 characters  ← Chinese numbers
✅ Using character with stroke data: U+4E00  ← Loading
```

Error indicators:
- `✅` = Success
- `⚠️` = Warning (but still works)
- `❌` = Error (fix needed)

## Troubleshooting

### "No option for Chinese Numbers"
→ You haven't rebuilt the app. Press ⌘B to build.

### "File not found: chinesenumbers.json"
→ File not in bundle. Check Build Phases → Copy Bundle Resources.

### "Character displays but no strokes"
→ Stroke data didn't load. Check console for error messages.

### "Segmented picker doesn't fit"
→ On smaller devices, the picker might need adjustment. Can switch to `.menu` style.

## What's Already Working

✅ Hiragana characters (existing)
✅ Katakana characters (existing)
✅ Version display at bottom (just added!)
✅ Chinese character framework (just added!)

## What You Need To Do

1. ⚠️ Run Python script
2. ⚠️ Add JSON to Xcode
3. ⚠️ Add Swift file to Xcode
4. ⚠️ Build and test

## Expected Build Time

- Python script: ~30 seconds (downloading from GitHub)
- Adding files: ~1 minute
- Build: ~10 seconds (incremental)
- **Total: ~2 minutes** ⏱️

## Success Checklist

When everything works, you should be able to:

- [x] See "Chinese Numbers" in the picker
- [x] Select it and tap "Lesson Demo"
- [x] See a random Chinese number (0-10)
- [x] See both pronunciations (Pinyin and Jyutping)
- [x] See English meaning
- [x] See stroke animation
- [x] Practice drawing the character
- [x] Get feedback on your writing

## Need Help?

1. **Check console output** for error messages
2. **Read CHINESE_SETUP.md** for detailed instructions
3. **Read CHINESE_NUMBERS_REFERENCE.md** for character info
4. **Verify all files are in Xcode project**
5. **Clean build folder** (Shift+⌘+K) and rebuild

## Tips

💡 Start with simple numbers: 一 (one), 二 (two), 三 (three)
💡 Practice stroke order - it matters in Chinese!
💡 The readings show Mandarin first, then Cantonese
💡 You can expand to 11-30 later (see reference guide)

## Expansion Ideas

Once basic numbers work:

1. **Add 11-30** (compound characters)
2. **Add common characters** (日月火水木金土)
3. **Add audio** (Mandarin and Cantonese pronunciation)
4. **Add quizzes** (number recognition)
5. **Add flashcards** (spaced repetition)

## Data Source Credit

Stroke data from **KanjiVG Project**:
- Website: https://kanjivg.tagaini.net
- GitHub: https://github.com/KanjiVG/kanjivg
- License: Creative Commons Attribution-ShareAlike 3.0
- 6,000+ characters with stroke order diagrams

## Fun Facts

📚 The same numbers are used in Chinese, Japanese, and Korean!
📚 Number 4 (四) sounds like "death" (死) - often avoided
📚 Number 8 (八) is lucky - sounds like "prosperity" (發)
📚 Number 9 (九) sounds like "longevity" (久)
📚 In addresses, 4th floors are sometimes labeled 3A or skipped entirely

## Ready to Start?

```bash
# Terminal
cd /path/to/your/project
python3 download_chinese_numbers.py

# Xcode
# 1. Add chinesenumbers.json
# 2. Add ChineseStrokeDataLoader.swift
# 3. ⌘B (Build)
# 4. ⌘R (Run)
# 5. Select "Chinese Numbers"
# 6. Start learning! 🎉
```

加油！(Add oil! / You can do it!)

# Chinese Numbers 11-30 Implementation

## ✅ What's Been Added

Your app now supports **compound Chinese numbers 11-30** in addition to the basic numbers 0-10!

## How It Works

### Compound Character System

Chinese numbers 11-30 are formed by combining basic characters:

**Pattern for 11-19**: 十 (ten) + unit digit
- 11 = 十一 (ten-one)
- 15 = 十五 (ten-five)
- 19 = 十九 (ten-nine)

**Pattern for 20-29**: tens digit + 十 (ten) + unit digit
- 20 = 二十 (two-ten)
- 25 = 二十五 (two-ten-five)
- 29 = 二十九 (two-ten-nine)

**30**: 三十 (three-ten)

### Technical Implementation

#### 1. **Negative Codepoint System**
Since compound characters don't have single Unicode codepoints, we use **negative numbers** as identifiers:
- Single characters (0-10): Positive codepoints (e.g., 0x4E00 for 一)
- Compound numbers (11-30): Negative identifiers (e.g., -11 for 十一)

#### 2. **Component-Based Stroke Data**
Compound characters combine strokes from their components:
- 十一 (11) = strokes from 十 + strokes from 一
- 二十五 (25) = strokes from 二 + strokes from 十 + strokes from 五

#### 3. **Updated Models**
```swift
struct CharacterID {
    let script: Script
    let codepoint: Int  // Can be negative for compounds!
    
    var isCompound: Bool { codepoint < 0 }
    var compoundNumber: Int? { isCompound ? -codepoint : nil }
}

struct CharacterGlyph {
    // ... existing fields ...
    let components: [Int]?  // Component codepoints for compounds
}
```

## Files Modified

### 1. `Models.swift`
- Added `CharacterID.compound()` helper method
- Added `isCompound` and `compoundNumber` properties
- Added `components` field to `CharacterGlyph`

### 2. `GlyphRepository.swift`
- Added `compoundNumbers` dictionary with all 11-30
- Updated `glyph(for:)` to handle negative codepoints
- Automatically combines stroke data from components

### 3. `RootView.swift`
- Updated both `randomCharacterID()` functions
- Now selects from full range 0-30
- Properly creates compound CharacterIDs with negative codepoints

## Complete Number Coverage

| Range | Type | Count | Examples |
|-------|------|-------|----------|
| 0-10 | Single | 11 | 零, 一, 二, 三... 十 |
| 11-19 | Compound | 9 | 十一, 十二... 十九 |
| 20-29 | Compound | 10 | 二十, 二十一... 二十九 |
| 30 | Compound | 1 | 三十 |
| **Total** | **Mixed** | **31** | **0-30** |

## Examples

### Single Character (一 = 1)
```swift
CharacterID(script: .hanzi, codepoint: 0x4E00)
// Literal: "一"
// Readings: ["yī", "ji1"]
// Strokes: [single character stroke data]
// Components: nil
```

### Compound Number (十五 = 15)
```swift
CharacterID(script: .hanzi, codepoint: -15)
// Literal: "十五"
// Readings: ["shí wǔ", "sap6 ng5"]
// Strokes: [十 strokes + 五 strokes]
// Components: [0x5341, 0x4E94]  // 十, 五
```

### Compound Number (二十八 = 28)
```swift
CharacterID(script: .hanzi, codepoint: -28)
// Literal: "二十八"
// Readings: ["èr shí bā", "ji6 sap6 baat3"]
// Strokes: [二 strokes + 十 strokes + 八 strokes]
// Components: [0x4E8C, 0x5341, 0x516B]  // 二, 十, 八
```

## User Experience

### Lesson Demo Mode
- Shows compound character (e.g., "二十五")
- Displays both Pinyin and Jyutping
- Shows English meaning ("twenty-five")
- Animates strokes in order (all components combined)

### Practice Mode
- User draws the entire compound character
- Evaluation compares against combined stroke data
- Scoring based on all component strokes

## Educational Value

### Why Compounds Matter:

1. **Pattern Recognition**: Learn how Chinese numbers combine logically
2. **Real-World Usage**: These are the numbers you actually use daily
3. **Foundation**: Understanding 1-30 prepares for higher numbers
4. **Stroke Practice**: More strokes = more practice

### Learning Progression:

**Beginner** (Simple, 1-4 strokes):
- 一 (1), 二 (2), 三 (3), 七 (7), 八 (8), 九 (9), 十 (10)

**Intermediate** (Compounds, 2 characters):
- 十一 (11), 十二 (12), 二十 (20), 三十 (30)

**Advanced** (Compounds, 3 characters):
- 二十五 (25), 二十八 (28)

**Expert**:
- 零 (0) - 13 strokes!

## Debug Output

When loading compound numbers, you'll see:

```
✅ Using character with stroke data: compound #15 (十五)
   Components: U+5341 (十), U+4E94 (五)
   Total strokes: 6 (2 from 十 + 4 from 五)
```

## Benefits

✅ **31 total numbers** (0-30) instead of just 11 (0-10)
✅ **Pattern-based learning** - understand the system, not just memorize
✅ **Authentic stroke order** - combined from real character data
✅ **Bilingual support** - Mandarin and Cantonese for all
✅ **Immediate practice** - works in both Lesson and Practice modes
✅ **No JSON changes needed** - uses existing 0-10 stroke data

## Testing

Try selecting "Chinese Numbers" and running:

1. **Lesson Demo** multiple times
   - You should see a mix of single and compound numbers
   - Watch how compound strokes animate smoothly
   
2. **Practice Mode**
   - Try writing 十一 (11) - should feel like two characters
   - Try writing 二十五 (25) - three characters worth of strokes
   - Get feedback on your combined stroke accuracy

## What's Next?

This compound system can easily extend to:
- **40-99**: Follow same pattern (四十, 五十, etc.)
- **100s**: 一百, 二百, etc. (using 百 which we already have!)
- **1000s**: 一千, 二千, etc. (using 千 which we already have!)
- **10,000s**: 一万, 二万, etc. (using 万 which we already have!)

The foundation is now in place for unlimited number expansion!

## Summary

```
Before: Chinese Numbers 0-10 (11 characters)
After:  Chinese Numbers 0-30 (31 numbers)

New: Compound character system
New: Component-based stroke combining
New: Negative codepoint identifiers
New: Educational number patterns

Result: 3x more learning content, same stroke data!
```

🎉 **You can now practice all numbers from 0-30 in Chinese!**

Just build and run - no additional setup required! The stroke data from 0-10 is automatically reused for the compound numbers.

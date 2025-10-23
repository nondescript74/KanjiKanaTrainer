# Chinese Numbers 0-30 Complete Reference

## Single Characters (0-10) - Already Implemented ✅

| # | Character | Pinyin | Jyutping | Unicode | Meaning |
|---|-----------|--------|----------|---------|---------|
| 0 | 〇 | líng | ling4 | U+3007 | zero |
| 1 | 一 | yī | ji1 | U+4E00 | one |
| 2 | 二 | èr | ji6 | U+4E8C | two |
| 3 | 三 | sān | saam1 | U+4E09 | three |
| 4 | 四 | sì | sei3 | U+56DB | four |
| 5 | 五 | wǔ | ng5 | U+4E94 | five |
| 6 | 六 | liù | luk6 | U+516D | six |
| 7 | 七 | qī | cat1 | U+4E03 | seven |
| 8 | 八 | bā | baat3 | U+516B | eight |
| 9 | 九 | jiǔ | gau2 | U+4E5D | nine |
| 10 | 十 | shí | sap6 | U+5341 | ten |

## Compound Numbers (11-19)

These are formed by combining 十 (ten) with the units digit.

| # | Characters | Pinyin | Jyutping | Literal Translation |
|---|------------|--------|----------|---------------------|
| 11 | 十一 | shí yī | sap6 jat1 | ten-one |
| 12 | 十二 | shí èr | sap6 ji6 | ten-two |
| 13 | 十三 | shí sān | sap6 saam1 | ten-three |
| 14 | 十四 | shí sì | sap6 sei3 | ten-four |
| 15 | 十五 | shí wǔ | sap6 ng5 | ten-five |
| 16 | 十六 | shí liù | sap6 luk6 | ten-six |
| 17 | 十七 | shí qī | sap6 cat1 | ten-seven |
| 18 | 十八 | shí bā | sap6 baat3 | ten-eight |
| 19 | 十九 | shí jiǔ | sap6 gau2 | ten-nine |

## Compound Numbers (20-29)

These are formed by combining the tens digit with 十 (ten), optionally followed by the units digit.

| # | Characters | Pinyin | Jyutping | Literal Translation |
|---|------------|--------|----------|---------------------|
| 20 | 二十 | èr shí | ji6 sap6 | two-ten |
| 21 | 二十一 | èr shí yī | ji6 sap6 jat1 | two-ten-one |
| 22 | 二十二 | èr shí èr | ji6 sap6 ji6 | two-ten-two |
| 23 | 二十三 | èr shí sān | ji6 sap6 saam1 | two-ten-three |
| 24 | 二十四 | èr shí sì | ji6 sap6 sei3 | two-ten-four |
| 25 | 二十五 | èr shí wǔ | ji6 sap6 ng5 | two-ten-five |
| 26 | 二十六 | èr shí liù | ji6 sap6 luk6 | two-ten-six |
| 27 | 二十七 | èr shí qī | ji6 sap6 cat1 | two-ten-seven |
| 28 | 二十八 | èr shí bā | ji6 sap6 baat3 | two-ten-eight |
| 29 | 二十九 | èr shí jiǔ | ji6 sap6 gau2 | two-ten-nine |
| 30 | 三十 | sān shí | saam1 sap6 | three-ten |

## Implementation Strategy

### Phase 1: Basic Numbers (0-10) ✅ COMPLETE
- Single character strokes from KanjiVG
- Easiest to implement
- Best for initial learning
- **Status: Implemented and ready to use**

### Phase 2: Teen Numbers (11-19)
For compound characters, you have two options:

#### Option A: Teach Components Separately
- User practices 十 (ten) separately
- User practices unit digits (一-九) separately  
- App shows "11 = 十 + 一" as a learning aid
- No new stroke data needed

#### Option B: Create Combined Stroke Data
- Download stroke data for multi-character sequences
- This would require custom SVG generation or layout
- More complex but provides integrated practice

**Recommendation**: Start with Option A (component-based learning)

### Phase 3: Twenties and Thirty (20-30)
- Same strategy as Phase 2
- All necessary components already available (二, 三, 十, 0-9)

## Adding Compound Number Support to the App

To support compound numbers (11-30), modify `GlyphRepository.swift`:

```swift
// Add this to the hanzi dictionary
private static let hanziCompounds: [Int: (literal: String, readings: [String], meaning: [String], components: [UInt32])] = {
    var map: [Int: (literal: String, readings: [String], meaning: [String], components: [UInt32])] = [:]
    let entries: [(Int, String, [String], [String], [UInt32])] = [
        // 11-19
        (11, "十一", ["shí yī", "sap6 jat1"], ["eleven"], [0x5341, 0x4E00]),
        (12, "十二", ["shí èr", "sap6 ji6"], ["twelve"], [0x5341, 0x4E8C]),
        (13, "十三", ["shí sān", "sap6 saam1"], ["thirteen"], [0x5341, 0x4E09]),
        (14, "十四", ["shí sì", "sap6 sei3"], ["fourteen"], [0x5341, 0x56DB]),
        (15, "十五", ["shí wǔ", "sap6 ng5"], ["fifteen"], [0x5341, 0x4E94]),
        // ... etc
    ]
    for (num, lit, readings, meanings, components) in entries {
        map[num] = (literal: lit, readings: readings, meaning: meanings, components: components)
    }
    return map
}()
```

Then update the glyph loading to handle compound characters by combining the stroke data from individual components.

## Learning Order Recommendations

### Beginner Path:
1. Numbers 1-5
2. Number 10 (十)
3. Numbers 6-9
4. Number 0 (〇)

### Intermediate Path:
5. Teen numbers (11-19) - learn as "10 + X"
6. Multiples of ten (20, 30) - learn as "X × 10"

### Advanced Path:
7. Complete 20-29
8. Larger numbers (百, 千, 万)

## Cultural Notes

### Mandarin vs. Cantonese
Both use the **same written characters** but pronounce them differently:
- **Mandarin** (Pinyin): Used in mainland China, Taiwan, Singapore
- **Cantonese** (Jyutping): Used in Hong Kong, Macau, Guangdong

The app includes both pronunciations for complete learning.

### Traditional vs. Simplified
These basic numbers are the **same in both systems**. The characters 0-10 did not change during simplification, making them perfect for learning both traditional and simplified Chinese.

### Special Cases

#### The number 2:
- 二 (èr) is used in counting and phone numbers
- 两 (liǎng) is used before measure words: 两个 = "two (of something)"

#### The number 0:
- 〇 (líng) is standard in Taiwan/Hong Kong
- 零 (líng) is an alternative (same pronunciation, more complex)

#### Money exception:
- For amounts, 两 (liǎng) replaces 二 for "20": 二十 → 两十
- Though 二十 is also acceptable in casual speech

## Next Steps for App Enhancement

1. **Stroke Order Animation** - Show proper stroke sequence
2. **Audio Pronunciation** - Add Mandarin and Cantonese audio
3. **Compound Character Practice** - Practice 十一, 二十, etc.
4. **Number Recognition Quiz** - Show character, user types number
5. **Number Writing Quiz** - Show number, user writes character
6. **Practical Applications** - Dates, prices, phone numbers

## Resources

- **KanjiVG**: https://github.com/KanjiVG/kanjivg - Stroke order data
- **Jyutping**: https://en.wikipedia.org/wiki/Jyutping - Cantonese romanization
- **Pinyin**: https://en.wikipedia.org/wiki/Pinyin - Mandarin romanization
- **Unicode**: https://unicode.org/charts/PDF/U4E00.pdf - CJK Unified Ideographs

## Testing Checklist

- [ ] Run `download_chinese_numbers.py`
- [ ] Add `chinesenumbers.json` to Xcode project
- [ ] Add `ChineseStrokeDataLoader.swift` to project
- [ ] Build project successfully
- [ ] Select "Chinese Numbers" in picker
- [ ] Test Lesson Demo with Chinese numbers
- [ ] Test Practice mode with Chinese numbers
- [ ] Verify stroke data displays correctly
- [ ] Check that readings show (Pinyin and Jyutping)
- [ ] Verify meanings display in English
- [ ] Test evaluation/scoring system

Good luck with your Chinese character learning app! 加油！(jiā yóu - "add oil" = "you can do it!")

# Adding Chinese Numbers to KanjiKanaTrainer

This guide explains how to add Chinese number support (0-30) to your KanjiKanaTrainer app.

## Overview

The app now supports three script types:
- **Hiragana** - Japanese phonetic script
- **Katakana** - Japanese phonetic script  
- **Chinese Numbers** - Chinese characters for numbers 0-10 (with support for more)

## Step 1: Download Stroke Data

Run the Python script to download stroke data from KanjiVG:

```bash
python3 download_chinese_numbers.py
```

This will:
1. Download SVG files for Chinese numbers from KanjiVG
2. Parse the stroke data
3. Create `strokedata/chinesenumbers.json`

The script downloads these characters:
- **Numbers 0-10**: 〇 (0), 一 (1), 二 (2), 三 (3), 四 (4), 五 (5), 六 (6), 七 (7), 八 (8), 九 (9), 十 (10)
- **Bonus characters**: 百 (hundred), 千 (thousand), 万 (ten thousand), 億 (hundred million)

## Step 2: Add JSON to Xcode Project

1. Open your Xcode project
2. Drag `strokedata/chinesenumbers.json` into your project
3. Make sure:
   - ✅ "Copy items if needed" is checked
   - ✅ Your app target is selected
   - ✅ The file appears in **Build Phases → Copy Bundle Resources**

## Step 3: Update Your Code

The following files have been created/updated:

### New Files:
- `ChineseStrokeDataLoader.swift` - Loads Chinese character stroke data
- `download_chinese_numbers.py` - Script to download stroke data

### Updated Files:
- `GlyphRepository.swift` - Added Chinese character data and lookup
- `RootView.swift` - Added "Chinese Numbers" option to the picker
- `Models.swift` - Already had `.hanzi` script type defined!

## Step 4: Build and Run

1. Build your project (⌘B)
2. Run on simulator or device
3. Select "Chinese Numbers" from the picker
4. Try both "Lesson Demo" and "Practice Random Character"

## Character Data Structure

Each Chinese character includes:
- **Literal**: The character itself (e.g., "一")
- **Readings**: Pinyin (Mandarin) and Jyutping (Cantonese)
  - Example: ["yī", "ji1"] for 一
- **Meaning**: English translation (e.g., ["one"])
- **Strokes**: Detailed stroke path data from KanjiVG

## Extending to More Characters

To add more Chinese characters (11-30 or beyond):

### Option 1: Update the Python script
1. The script already has structure for 11-30 as compounds (十一, 十二, etc.)
2. For single characters, add them to `CHINESE_NUMBERS` dict
3. Re-run the script

### Option 2: Add common Kanji/Hanzi
The KanjiVG database has **6000+ characters**. To add more:

1. Find the Unicode codepoint (e.g., 0x5B66 for 学)
2. Add to `GlyphBundleRepository.hanzi` dict in `GlyphRepository.swift`:
```swift
(0x5B66, "学", ["xué", "hok6"], ["study", "learning"])
```
3. Add to the download script and re-run to get stroke data

## Troubleshooting

### "No stroke data found"
- Verify the JSON file is in your project's Bundle Resources
- Check the console for debug messages about file loading
- Make sure the file is named exactly `chinesenumbers.json`

### "Character not displaying"
- Verify the Unicode codepoint is correct
- Check that the character is in the `hanzi` dictionary in `GlyphRepository.swift`
- Look for error messages in the Xcode console

### "Script not found error"
- Make sure you're using `.hanzi` script type (not `.kanji`)
- Verify the character is in the Chinese character range

## Architecture Notes

The app uses a modular architecture:

1. **StrokeDataLoader** → Loads Kana stroke data
2. **ChineseStrokeDataLoader** → Loads Chinese stroke data  
3. **GlyphRepository** → Provides character metadata (readings, meanings)
4. **RootView** → UI for selecting script and mode

Each script type can have its own:
- Stroke data JSON file
- Data loader class
- Character range
- Metadata structure

## Next Steps

Once Chinese numbers are working, you can:
- Add numbers 11-30 (compound characters like 十一)
- Add more basic Hanzi (common characters)
- Create separate practice modes by difficulty
- Add stroke order animation
- Implement spaced repetition learning

## Chinese Number Reference

| Number | Character | Pinyin | Jyutping | Strokes |
|--------|-----------|--------|----------|---------|
| 0 | 〇 | líng | ling4 | 1 |
| 1 | 一 | yī | ji1 | 1 |
| 2 | 二 | èr | ji6 | 2 |
| 3 | 三 | sān | saam1 | 3 |
| 4 | 四 | sì | sei3 | 5 |
| 5 | 五 | wǔ | ng5 | 4 |
| 6 | 六 | liù | luk6 | 4 |
| 7 | 七 | qī | cat1 | 2 |
| 8 | 八 | bā | baat3 | 2 |
| 9 | 九 | jiǔ | gau2 | 2 |
| 10 | 十 | shí | sap6 | 2 |

**Note**: Numbers 11-30 are typically written as compounds:
- 11 = 十一 (shí yī) = "ten-one"
- 20 = 二十 (èr shí) = "two-ten"
- 21 = 二十一 (èr shí yī) = "two-ten-one"
- etc.

## Questions or Issues?

The stroke data comes from the [KanjiVG project](https://github.com/KanjiVG/kanjivg), which provides stroke order diagrams for Kanji, Kana, and Hanzi characters.

For app-specific issues, check the Xcode console for debug messages that start with:
- `✅` = Success
- `⚠️` = Warning
- `❌` = Error

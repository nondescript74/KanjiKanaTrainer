# Chinese Stroke Fetcher - Working URLs

## The Correct URL

After checking the actual GitHub repository at https://github.com/chanind/hanzi-writer-data, the files use the **actual character** in the filename, not hex codes!

```
https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/{character}.json
```

Where `{character}` is the literal Chinese character (人, 水, 火, etc.).

## Examples

| Character | Working URL |
|-----------|-------------|
| 人 (person) | https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/人.json |
| 水 (water) | https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/水.json |
| 火 (fire) | https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/火.json |
| 一 (one) | https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/一.json |

## Test It

```bash
python3 test_urls.py
```

**Expected output:**
```
Testing hanzi-writer-data URLs...

Testing: 人 (U+04EBA)
  URL: https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/人.json
  ✅ SUCCESS - 2 strokes

Testing: 水 (U+06C34)
  URL: https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/水.json
  ✅ SUCCESS - 4 strokes

Testing: 火 (U+0706B)
  URL: https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/火.json
  ✅ SUCCESS - 4 strokes

Testing: 一 (U+04E00)
  URL: https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/一.json
  ✅ SUCCESS - 1 strokes

If all tests passed, the URLs are working correctly!
You can now run: python3 chinese_stroke_fetcher.py
```

## Run the Full Script

```bash
python3 chinese_stroke_fetcher.py
```

This will:
- Fetch stroke data for 100 common Chinese characters
- Take about 30-60 seconds with rate limiting (0.3s delay between requests)
- Create `chinese_stroke_data.json` and `stroke_data_swift.json`

## What Changed

**Both scripts now use the simple GitHub raw URL:**

### chinese_stroke_fetcher.py
```python
# Uses the actual character in the URL!
url = f"https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/{character}.json"
```

### test_urls.py  
```python
# Uses the actual character in the URL!
url = f"https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/{char}.json"
```

## Data Format

Each JSON file contains:
```json
{
  "character": "人",
  "strokes": [
    "M 345 735 Q 357 750 ...",
    "M 579 563 Q 624 629 ..."
  ],
  "medians": [
    [[345, 735], [357, 750], ...],
    [[579, 563], [624, 629], ...]
  ],
  "radical": "人"
}
```

## Offline Option

If you don't have internet or GitHub is blocked:

```bash
python3 chinese_stroke_fetcher.py --embedded
```

This uses built-in stroke count data (simplified, but works completely offline).

## Repository Structure

The hanzi-writer-data repository structure:
```
hanzi-writer-data/
├── data/
│   ├── 一.json  (one)
│   ├── 人.json  (person)
│   ├── 水.json  (water)
│   ├── 火.json  (fire)
│   └── ... (thousands more)
└── README.md
```

All character data files use the **actual character** as the filename!

## Success!

Once the scripts run successfully, you'll have JSON files ready to add to your Xcode project:

1. **chinese_stroke_data.json** - Standard format
2. **stroke_data_swift.json** - Swift-compatible format

Then just:
1. Drag into Xcode `strokedata` folder
2. Check "Copy items if needed"
3. Build & Run!

---

**Repository:** https://github.com/chanind/hanzi-writer-data  
**License:** MIT  
**Data Source:** Based on KanjiVG stroke order data

# Regenerate JSON with Correct Format

## Problem

The `chinese_stroke_data.json` file you just created needs to be in a specific format for the Swift app:

1. **Dictionary format** (not array) with `"U+XXXX"` keys
2. **Stroke data as point arrays** (using `medians` from GitHub, not SVG paths)
3. **Each point has x, y, t values**

## Solution

I've updated the `chinese_stroke_fetcher.py` script to generate the correct format!

### Step 1: Delete Old File

```bash
rm chinese_stroke_data.json
rm stroke_data_swift.json
```

### Step 2: Re-run the Fetcher

```bash
python3 chinese_stroke_fetcher.py
```

This will create a NEW `chinese_stroke_data.json` with the correct format.

### Step 3: Replace in Xcode

1. In Xcode, **delete** the old `chinese_stroke_data.json` from the `strokedata` folder
2. Drag the **new** `chinese_stroke_data.json` into the `strokedata` folder
3. Check ✅ "Copy items if needed"
4. Select your app target

### Step 4: Build & Test

```bash
# In Xcode:
⌘⇧K  # Clean
⌘B   # Build
⌘R   # Run
```

Check the console for:
```
🔍 Loading Chinese character stroke data...
✅ Loaded 15 characters from Numbers (total: 15)
✅ Loaded 100 characters from Common Characters (total: 115)
```

## The Correct JSON Format

The new file will look like this:

```json
{
  "U+4EBA": {
    "character": "人",
    "codepoint": 20154,
    "strokes": [
      [
        {"x": 345, "y": 735, "t": 0.0},
        {"x": 357, "y": 750, "t": 0.5},
        {"x": 380, "y": 780, "t": 1.0}
      ],
      [
        {"x": 579, "y": 563, "t": 0.0},
        {"x": 624, "y": 629, "t": 0.5},
        {"x": 654, "y": 689, "t": 1.0}
      ]
    ]
  },
  "U+6C34": {
    "character": "水",
    "codepoint": 27700,
    "strokes": [...]
  },
  ...
}
```

## What Changed

### Old Format (Array - Wrong):
```json
[
  {
    "character": "人",
    "unicode": "4eba",
    "strokes": ["M 345 735 Q...", "M 579 563 Q..."],  ← SVG paths
    "medians": [[[345, 735], [357, 750]...]]
  }
]
```

### New Format (Dictionary - Correct):
```json
{
  "U+4EBA": {
    "character": "人",
    "codepoint": 20154,
    "strokes": [
      [{"x": 345, "y": 735, "t": 0.0}, ...]  ← Point arrays
    ]
  }
}
```

## Key Differences

1. **Top level**: Dictionary (`{}`) not array (`[]`)
2. **Keys**: `"U+4EBA"` format (uppercase, 4+ digits)
3. **Stroke data**: Uses `medians` (coordinate arrays) not `strokes` (SVG paths)
4. **Point format**: Objects with `x`, `y`, `t` properties
5. **Time values**: Calculated as progression through stroke (0.0 to 1.0)

## After Re-running

Once you have the new file:

1. ✅ Characters will appear in Demo (random selection)
2. ✅ Characters will appear in Practice
3. ✅ All 115 characters (15 numbers + 100 common) available
4. ✅ Proper stroke animations
5. ✅ Correct stroke order

## Test It

In your app:
1. Select "Chinese Numbers"
2. Tap "Demo" several times
   - You should see various characters, not just 0-30
   - New characters: 人 水 火 日 月 etc.
3. Tap "Practice"
   - Draw any character you see
   - Should get proper feedback

## If You See Only Numbers 0-30

That means:
- The old JSON file is still loaded, OR
- The new JSON wasn't generated correctly

Solution:
1. Check console output from Python script
2. Verify the JSON file format (should be dictionary at top level)
3. Re-add to Xcode project
4. Clean build & retry

---

**Once regenerated with the correct format, your 100 characters will work automatically!** 🎉

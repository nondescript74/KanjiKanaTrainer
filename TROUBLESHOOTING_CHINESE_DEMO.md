# Troubleshooting: Chinese Demo Not Playing

## Problem
When you select sequential demo for Chinese common characters (Body Parts, Nature, Verbs, etc.), clicking "Play Demo" or "Tap Play to Start" does nothing. However, "Numbers 1-10" works fine.

## Root Cause
✅ The **code** for 100 common characters is complete  
✅ The **metadata** in GlyphRepository.swift exists  
❌ The **stroke data JSON file** doesn't have the 100 characters yet

**Why Numbers 1-10 works:** The `chinesenumbers.json` file already exists with stroke data for 0-10.

**Why new characters don't work:** The `chinese_stroke_data.json` file hasn't been generated yet, so characters like 人, 水, 火, etc. have no stroke data to animate.

## Solution: Generate the Stroke Data JSON

### Step 1: Navigate to the Chinese folder
```bash
cd Chinese
```

### Step 2: Run the Python script
```bash
python3 chinese_stroke_fetcher.py
```

This will:
- Download stroke order data from HanziWriter GitHub
- Create `chinese_stroke_data.json` with all 100 characters
- Save it in the Chinese folder

**If you have network issues:**
```bash
python3 chinese_stroke_fetcher.py --embedded
```
(This uses built-in stroke count data and works offline)

### Step 3: Add the JSON file to Xcode

1. **Locate the file:** Find `chinese_stroke_data.json` in your Chinese folder
2. **Drag to Xcode:** Drag it into the `strokedata` folder in Xcode's Project Navigator
3. **Configure in dialog:**
   - ✅ Check "Copy items if needed"
   - ✅ Select your app target (KanjiKanaTrainer)
   - Click "Add"

### Step 4: Verify Build Phase

1. In Xcode, select your project
2. Select your app target
3. Go to "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. Verify `chinese_stroke_data.json` is listed
   - If you see it listed **twice**, remove one (this causes build errors)

### Step 5: Clean and Rebuild

```
⌘⇧K  (Clean Build Folder)
⌘B   (Build)
⌘R   (Run)
```

### Step 6: Check Console Output

Look for these messages when the app launches:
```
🔍 Loading Chinese character stroke data...
✅ Loaded 15 characters from Numbers (total: 15)
✅ Loaded 100 characters from Common Characters (total: 115)
```

If you see:
```
⚠️ chinese_stroke_data.json NOT FOUND - Common Characters will be unavailable
```
Then the file wasn't added correctly to the bundle.

## How to Verify It's Working

### Test a Simple Character Set
1. Navigate to "Sequential Demo" → "Chinese Characters"
2. Select "Body Parts & People" (8 characters)
3. You should see: **人** (person) displayed with metadata
4. Click "Play Demo" → Should animate stroke-by-stroke
5. Should hear pronunciation "rén"

### What You Should See
- Character: **人**
- Meaning: "person, people"
- Stroke animation: 2 strokes drawing automatically
- Voice: Chinese pronunciation

### If It Still Doesn't Work

Check these common issues:

#### Issue 1: JSON file not in bundle
**Symptom:** Console shows "chinese_stroke_data.json NOT FOUND"  
**Fix:** Re-add the file to Xcode, making sure to check your app target

#### Issue 2: JSON file is malformed
**Symptom:** Console shows "Failed to decode Common Characters"  
**Fix:** Re-run the Python script to regenerate the file

#### Issue 3: Python script error
**Symptom:** Script fails with import errors  
**Fix:** Make sure you have Python 3 installed:
```bash
python3 --version  # Should show Python 3.x
```

#### Issue 4: Characters not in JSON
**Symptom:** Some characters work, others don't  
**Fix:** Check that your `chinese_stroke_fetcher.py` includes all 100 characters in the `BASIC_CHARACTERS` list

## Quick Diagnostic Test

Run this in your Python script directory:
```bash
# Check if the JSON file exists
ls -lh chinese_stroke_data.json

# Count how many characters are in it
python3 -c "import json; print(len(json.load(open('chinese_stroke_data.json'))))"
```

Expected output: `100` (or more)

## Alternative: Use Pre-generated JSON

If the Python script doesn't work for you, the JSON file structure is:

```json
{
  "U+4EBA": {
    "character": "人",
    "codepoint": 19978,
    "strokes": [
      [
        {"x": 440.0, "y": 141.0, "t": 0.0},
        {"x": 442.0, "y": 155.0, "t": 0.1},
        ...
      ],
      [...]
    ]
  },
  ...
}
```

You can manually create a minimal version for testing with just a few characters.

## Summary

**The code is ready. You just need the data file!**

1. ✅ Code updated (SequentialDemoViewModel, SequentialPracticeViewModel)
2. ✅ UI updated (ChineseDemoSetSelector, ChineseNumberSetSelector)
3. ✅ Metadata added (GlyphRepository.swift - 100 characters)
4. ✅ Loader updated (ChineseStrokeDataLoader.swift)
5. ❌ **Missing:** `chinese_stroke_data.json` with stroke data

**Once you generate and add the JSON file, all 100 characters will work perfectly!**

---

**After you complete these steps, the demo should work for all character categories.**

加油！🚀

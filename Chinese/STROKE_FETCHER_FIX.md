# Chinese Stroke Fetcher - Fixed URLs

## Problem
The script was using incorrect GitHub URLs that resulted in 404 errors:
- ❌ `https://raw.githubusercontent.com/chanind/hanzi-writer-data/master/data/{unicode}.json`
- ❌ Attempted to download non-existent `data.json` file

## Solution
Updated to use the correct **jsdelivr CDN** which serves the hanzi-writer-data npm package:
- ✅ `https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/{unicode}.json`
- ✅ Unicode formatted with 5 digits (e.g., `04eba` for 人)

## Changes Made

### 1. Fixed `fetch_from_github_raw()` function
- Changed URL to use jsdelivr CDN
- Fixed unicode formatting to use 5 digits with leading zeros
- Removed confusing debug print statements

### 2. Simplified `download_full_dataset()` function
- Removed attempt to download non-existent combined file
- Returns empty dict immediately since hanzi-writer-data doesn't have a combined file

### 3. Updated `main()` function
- Removed "Method 1" (full dataset download) since it doesn't exist
- Goes directly to individual character fetching
- Reduced delay to 0.3 seconds (CDN can handle it)
- Updated help text

## How to Use

### Option 1: Fetch from CDN (Recommended)
```bash
python3 chinese_stroke_fetcher.py
```

**What it does:**
- Fetches stroke data for 100 characters from jsdelivr CDN
- Takes ~30-60 seconds with rate limiting
- Creates accurate, complete stroke data

**Pros:**
- ✅ Complete stroke path data (SVG format)
- ✅ Accurate medians for animation
- ✅ Radical information
- ✅ Works with any internet connection

**Cons:**
- ⏱️ Takes a few minutes to download all 100 characters

### Option 2: Use Embedded Data (Offline)
```bash
python3 chinese_stroke_fetcher.py --embedded
```

**What it does:**
- Uses built-in stroke count data
- Generates simplified stroke paths
- Works completely offline

**Pros:**
- ⚡ Instant (no network needed)
- ✅ Accurate stroke counts
- ✅ All 100 characters included

**Cons:**
- ⚠️ Simplified stroke paths (not from actual data)
- ⚠️ Good for testing, but use CDN for production

## Test the Fix

Before running the full script, test that the URLs work:

```bash
python3 test_urls.py
```

**Expected output:**
```
Testing hanzi-writer-data URLs...

Testing: 人 (U+04EBA)
  URL: https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/04eba.json
  ✅ SUCCESS - 2 strokes

Testing: 水 (U+06C34)
  URL: https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/06c34.json
  ✅ SUCCESS - 4 strokes

Testing: 火 (U+0706B)
  URL: https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/0706b.json
  ✅ SUCCESS - 4 strokes

Testing: 一 (U+04E00)
  URL: https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/04e00.json
  ✅ SUCCESS - 1 strokes

If all tests passed, the URLs are working correctly!
```

## Example URLs

| Character | Unicode | URL |
|-----------|---------|-----|
| 人 (person) | U+4EBA | `https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/04eba.json` |
| 水 (water) | U+6C34 | `https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/06c34.json` |
| 火 (fire) | U+706B | `https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/0706b.json` |
| 一 (one) | U+4E00 | `https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/04e00.json` |

## Data Format

The CDN returns JSON like this:

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

## Troubleshooting

### Issue: "Failed to fetch" for all characters

**Possible causes:**
1. No internet connection
2. Firewall blocking jsdelivr CDN
3. DNS issues

**Solutions:**
```bash
# Test internet connectivity
curl -I https://cdn.jsdelivr.net

# If blocked, use embedded data
python3 chinese_stroke_fetcher.py --embedded

# Or try with longer timeout (edit script, change timeout=15 to timeout=30)
```

### Issue: Some characters fail, others succeed

**This is normal!** Some characters might not be in the hanzi-writer-data database.

**Check which succeeded:**
```bash
python3 chinese_stroke_fetcher.py | grep "✓"
```

**The script will:**
- Show you which characters succeeded
- Continue with the ones that worked
- Generate files with available data

### Issue: "Rate limited" or "Too many requests"

**Solution:** The script already includes delays. If you still get rate limited:

1. Edit `chinese_stroke_fetcher.py`
2. Find: `delay=0.3`
3. Change to: `delay=0.5` or `delay=1.0`

## What Gets Created

After running successfully, you'll have:

### 1. `chinese_stroke_data.json`
Standard format with array of character objects:
```json
[
  {
    "character": "人",
    "unicode": "04eba",
    "stroke_count": 2,
    "strokes": [...],
    "medians": [...],
    "radical": "人"
  },
  ...
]
```

### 2. `stroke_data_swift.json`
Swift-friendly format with camelCase keys:
```json
{
  "version": "1.0",
  "character_count": 100,
  "characters": {
    "人": {
      "unicode": "04eba",
      "strokeCount": 2,
      "strokes": [...],
      "medians": [...],
      "radical": "人"
    },
    ...
  }
}
```

## Next Steps

Once you have `chinese_stroke_data.json`:

1. **Add to Xcode:**
   - Drag into `strokedata` folder
   - Check "Copy items if needed"
   - Verify it's in Build Phases → Copy Bundle Resources

2. **Build & Run:**
   - Clean: ⌘⇧K
   - Build: ⌘B
   - Run: ⌘R

3. **Verify in console:**
   ```
   ✅ Loaded 15 characters from Numbers (total: 15)
   ✅ Loaded 100 characters from Common Characters (total: 115)
   ```

## References

- **Hanzi Writer**: https://hanziwriter.org
- **Data Repository**: https://github.com/chanind/hanzi-writer-data
- **CDN**: https://cdn.jsdelivr.net/npm/hanzi-writer-data
- **Unicode Tables**: https://www.unicode.org/charts/unihan.html

## Summary

The script now:
- ✅ Uses correct CDN URLs
- ✅ Fetches real stroke data
- ✅ Has offline fallback option
- ✅ Includes rate limiting
- ✅ Shows clear progress
- ✅ Creates Swift-compatible output

**Ready to run!** 🚀

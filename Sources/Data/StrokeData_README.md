# Stroke Data JSON Format

This directory contains stroke data for Japanese kana characters in JSON format.

## Directory Structure

```
StrokeData/
├── 3042.json  (あ - U+3042)
├── 3044.json  (い - U+3044)
├── 30A2.json  (ア - U+30A2)
└── ...
```

## File Naming Convention

Files are named using the **4-digit hexadecimal Unicode codepoint** (uppercase, zero-padded).

Examples:
- `3042.json` = U+3042 (hiragana "あ")
- `30A2.json` = U+30A2 (katakana "ア")
- `304B.json` = U+304B (hiragana "か")

## JSON Structure

Each JSON file contains stroke path data for a single character:

```json
{
  "strokes": [
    {
      "points": [
        {
          "x": 0.15,
          "y": 0.25,
          "t": 0.0
        },
        {
          "x": 0.18,
          "y": 0.28,
          "t": 0.05
        }
      ]
    }
  ]
}
```

### Field Descriptions

- `strokes` (array): Array of stroke paths, ordered by writing sequence
  - `points` (array): Array of points defining the stroke path
    - `x` (float): X coordinate (0.0 to 1.0, normalized)
    - `y` (float): Y coordinate (0.0 to 1.0, normalized)
    - `t` (float): Time offset in seconds for animation

### Coordinate System

- **Origin**: Top-left corner (0, 0)
- **Range**: 0.0 to 1.0 for both X and Y
- **Normalized**: Coordinates are relative to character bounding box

### Time Values

The `t` value represents the animation timing:
- First point should have `t: 0.0`
- Subsequent points increment based on stroke speed
- Typical increment: 0.05 seconds per point
- Can vary to simulate natural writing speed

## Example Files

See the example JSON files in this directory for reference implementations.

## Memory Efficiency

These JSON files are loaded **on-demand** rather than pre-loaded into memory, significantly reducing the app's memory footprint. Each file is loaded only when the specific character is needed.

## Source Data

Stroke data is derived from KanjiVG (http://kanjivg.tagaini.net/) and converted to this JSON format for efficient loading.

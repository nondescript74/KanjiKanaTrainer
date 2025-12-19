"""
Download and convert KanjiVG Chinese number SVG files to JSON stroke data.

Usage:
    python3 download_chinese_numbers.py

This script will:
1. Download Chinese number (0-30) SVG files from KanjiVG
2. Parse the SVG path data
3. Convert to normalized stroke coordinates
4. Generate JSON file with the stroke data
"""

import urllib.request
import xml.etree.ElementTree as ET
import json
import os
import re
from typing import List, Dict, Tuple

# KanjiVG GitHub raw content URL
KANJIVG_BASE_URL = "https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/"

# Chinese numbers 0-30 with their characters and Unicode codepoints
# Note: Using 零 (U+96F6) for zero instead of 〇 (U+3007) because KanjiVG has better coverage
CHINESE_NUMBERS = {
    0: ("零", 0x96F6),   # líng (zero) - traditional character
    1: ("一", 0x4E00),   # yī
    2: ("二", 0x4E8C),   # èr
    3: ("三", 0x4E09),   # sān
    4: ("四", 0x56DB),   # sì
    5: ("五", 0x4E94),   # wǔ
    6: ("六", 0x516D),   # liù
    7: ("七", 0x4E03),   # qī
    8: ("八", 0x516B),   # bā
    9: ("九", 0x4E5D),   # jiǔ
    10: ("十", 0x5341),  # shí
    11: ("十一", None),  # shí yī (compound)
    12: ("十二", None),  # shí èr (compound)
    13: ("十三", None),  # shí sān (compound)
    14: ("十四", None),  # shí sì (compound)
    15: ("十五", None),  # shí wǔ (compound)
    16: ("十六", None),  # shí liù (compound)
    17: ("十七", None),  # shí qī (compound)
    18: ("十八", None),  # shí bā (compound)
    19: ("十九", None),  # shí jiǔ (compound)
    20: ("二十", None),  # èr shí (compound)
    21: ("二十一", None),
    22: ("二十二", None),
    23: ("二十三", None),
    24: ("二十四", None),
    25: ("二十五", None),
    26: ("二十六", None),
    27: ("二十七", None),
    28: ("二十八", None),
    29: ("二十九", None),
    30: ("三十", None),  # sān shí (compound)
}

# Additional useful characters
EXTRA_CHARACTERS = {
    "百": 0x767E,   # bǎi (hundred)
    "千": 0x5343,   # qiān (thousand)
    "万": 0x4E07,   # wàn (ten thousand)
    "億": 0x5104,   # yì (hundred million)
}

# Output directory
OUTPUT_DIR = "strokedata"
JSON_OUTPUT = "chinesenumbers.json"


def download_svg(codepoint: int) -> str:
    """Download SVG file from KanjiVG for a given codepoint."""
    hex_code = f"{codepoint:05x}"
    url = f"{KANJIVG_BASE_URL}{hex_code}.svg"
    
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            return response.read().decode('utf-8')
    except Exception as e:
        print(f"  ⚠️  Failed to download U+{hex_code.upper()}: {e}")
        return None


def parse_svg_path(path_d: str) -> List[Tuple[float, float]]:
    """
    Parse SVG path 'd' attribute and extract coordinates.
    This is a simplified parser for common path commands (M, L, C, S, Q, T).
    """
    points = []
    
    # Remove commas and split by command letters
    path_d = path_d.replace(',', ' ')
    
    # Extract all numeric values
    numbers = re.findall(r'-?\d+\.?\d*', path_d)
    numbers = [float(n) for n in numbers]
    
    # Parse commands
    commands = re.findall(r'[MmLlHhVvCcSsQqTtAaZz]', path_d)
    
    num_idx = 0
    current_x, current_y = 0.0, 0.0
    
    for cmd in commands:
        if cmd in ['M', 'm']:  # MoveTo
            if num_idx + 1 < len(numbers):
                if cmd == 'M':  # Absolute
                    current_x, current_y = numbers[num_idx], numbers[num_idx + 1]
                else:  # Relative
                    current_x += numbers[num_idx]
                    current_y += numbers[num_idx + 1]
                points.append((current_x, current_y))
                num_idx += 2
                
        elif cmd in ['L', 'l']:  # LineTo
            if num_idx + 1 < len(numbers):
                if cmd == 'L':
                    current_x, current_y = numbers[num_idx], numbers[num_idx + 1]
                else:
                    current_x += numbers[num_idx]
                    current_y += numbers[num_idx + 1]
                points.append((current_x, current_y))
                num_idx += 2
                
        elif cmd in ['C', 'c']:  # Cubic Bezier
            if num_idx + 5 < len(numbers):
                # Sample the curve with control points
                if cmd == 'C':
                    x1, y1 = numbers[num_idx], numbers[num_idx + 1]
                    x2, y2 = numbers[num_idx + 2], numbers[num_idx + 1]
                    x3, y3 = numbers[num_idx + 4], numbers[num_idx + 5]
                else:
                    x1, y1 = current_x + numbers[num_idx], current_y + numbers[num_idx + 1]
                    x2, y2 = current_x + numbers[num_idx + 2], current_y + numbers[num_idx + 3]
                    x3, y3 = current_x + numbers[num_idx + 4], current_y + numbers[num_idx + 5]
                
                # Add sampled points along the curve
                for t in [0.25, 0.5, 0.75, 1.0]:
                    # Cubic Bezier formula
                    t2 = t * t
                    t3 = t2 * t
                    mt = 1 - t
                    mt2 = mt * mt
                    mt3 = mt2 * mt
                    
                    x = mt3 * current_x + 3 * mt2 * t * x1 + 3 * mt * t2 * x2 + t3 * x3
                    y = mt3 * current_y + 3 * mt2 * t * y1 + 3 * mt * t2 * y2 + t3 * y3
                    points.append((x, y))
                
                current_x, current_y = x3, y3
                num_idx += 6
                
        elif cmd in ['S', 's']:  # Smooth Cubic Bezier
            if num_idx + 3 < len(numbers):
                if cmd == 'S':
                    x2, y2 = numbers[num_idx], numbers[num_idx + 1]
                    x3, y3 = numbers[num_idx + 2], numbers[num_idx + 3]
                else:
                    x2, y2 = current_x + numbers[num_idx], current_y + numbers[num_idx + 1]
                    x3, y3 = current_x + numbers[num_idx + 2], current_y + numbers[num_idx + 3]
                
                # Sample the curve
                for t in [0.25, 0.5, 0.75, 1.0]:
                    t2 = t * t
                    t3 = t2 * t
                    mt = 1 - t
                    mt2 = mt * mt
                    mt3 = mt2 * mt
                    
                    x = mt3 * current_x + 3 * mt * t2 * x2 + t3 * x3
                    y = mt3 * current_y + 3 * mt * t2 * y2 + t3 * y3
                    points.append((x, y))
                
                current_x, current_y = x3, y3
                num_idx += 4
        
        elif cmd in ['Q', 'q']:  # Quadratic Bezier
            if num_idx + 3 < len(numbers):
                if cmd == 'Q':
                    x1, y1 = numbers[num_idx], numbers[num_idx + 1]
                    x2, y2 = numbers[num_idx + 2], numbers[num_idx + 3]
                else:
                    x1, y1 = current_x + numbers[num_idx], current_y + numbers[num_idx + 1]
                    x2, y2 = current_x + numbers[num_idx + 2], current_y + numbers[num_idx + 3]
                
                # Sample the quadratic curve
                for t in [0.25, 0.5, 0.75, 1.0]:
                    mt = 1 - t
                    x = mt * mt * current_x + 2 * mt * t * x1 + t * t * x2
                    y = mt * mt * current_y + 2 * mt * t * y1 + t * t * y2
                    points.append((x, y))
                
                current_x, current_y = x2, y2
                num_idx += 4
        
        elif cmd in ['H', 'h']:  # Horizontal line
            if num_idx < len(numbers):
                if cmd == 'H':
                    current_x = numbers[num_idx]
                else:
                    current_x += numbers[num_idx]
                points.append((current_x, current_y))
                num_idx += 1
        
        elif cmd in ['V', 'v']:  # Vertical line
            if num_idx < len(numbers):
                if cmd == 'V':
                    current_y = numbers[num_idx]
                else:
                    current_y += numbers[num_idx]
                points.append((current_x, current_y))
                num_idx += 1
    
    return points


def normalize_points(all_strokes: List[List[Tuple[float, float]]]) -> List[List[Dict]]:
    """
    Normalize all stroke points to 0-1 range based on the entire character's bounding box.
    Also adds timestamp 't' for animation.
    """
    if not all_strokes or not any(all_strokes):
        return []
    
    # Find global bounding box across all strokes
    all_points = [point for stroke in all_strokes for point in stroke]
    if not all_points:
        return []
    
    xs = [p[0] for p in all_points]
    ys = [p[1] for p in all_points]
    
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    
    # Avoid division by zero
    width = max_x - min_x if max_x > min_x else 1.0
    height = max_y - min_y if max_y > min_y else 1.0
    
    # Use the larger dimension to maintain aspect ratio
    scale = max(width, height)
    
    # Center the character
    offset_x = (scale - width) / 2
    offset_y = (scale - height) / 2
    
    normalized_strokes = []
    
    for stroke in all_strokes:
        if not stroke:
            continue
            
        normalized_stroke = []
        for i, (x, y) in enumerate(stroke):
            # Normalize coordinates
            norm_x = (x - min_x + offset_x) / scale
            norm_y = (y - min_y + offset_y) / scale
            
            # Add timestamp for animation (0.0 to 1.0 within each stroke)
            t = i / (len(stroke) - 1) if len(stroke) > 1 else 0.0
            
            normalized_stroke.append({
                "x": norm_x,
                "y": norm_y,
                "t": t
            })
        
        normalized_strokes.append(normalized_stroke)
    
    return normalized_strokes


def parse_kanjivg_svg(svg_content: str) -> List[List[Tuple[float, float]]]:
    """
    Parse KanjiVG SVG and extract stroke paths.
    Returns a list of strokes, where each stroke is a list of (x, y) points.
    """
    try:
        # Parse XML with namespace handling
        root = ET.fromstring(svg_content)
        
        # KanjiVG uses this namespace
        ns = {'svg': 'http://www.w3.org/2000/svg', 'kvg': 'http://kanjivg.tagaini.net'}
        
        strokes = []
        
        # Find all path elements (each path is typically one stroke)
        for path in root.findall('.//svg:path', ns):
            d = path.get('d')
            if d:
                points = parse_svg_path(d)
                if points:
                    strokes.append(points)
        
        return strokes
        
    except Exception as e:
        print(f"  ❌ Error parsing SVG: {e}")
        return []


def download_and_process_character(char: str, codepoint: int) -> Dict:
    """Download and process a single character."""
    print(f"Processing {char} (U+{codepoint:04X})...")
    
    svg_content = download_svg(codepoint)
    if not svg_content:
        return None
    
    strokes = parse_kanjivg_svg(svg_content)
    if not strokes:
        print(f"  ⚠️  No strokes found for {char}")
        return None
    
    normalized_strokes = normalize_points(strokes)
    
    key = f"U+{codepoint:04X}"
    data = {
        "character": char,
        "codepoint": codepoint,
        "strokes": normalized_strokes
    }
    
    print(f"  ✅ Processed {char} with {len(normalized_strokes)} strokes")
    return key, data


def main():
    """Main function to download and process all Chinese numbers."""
    print("=" * 60)
    print("Chinese Numbers Stroke Data Downloader")
    print("=" * 60)
    
    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    all_data = {}
    
    # Process basic numbers (0-10)
    print("\n📥 Downloading basic numbers (0-10)...")
    for num, (char, codepoint) in CHINESE_NUMBERS.items():
        if codepoint and num <= 10:  # Only single characters for now
            result = download_and_process_character(char, codepoint)
            if result:
                key, data = result
                all_data[key] = data
    
    # Process extra characters
    print("\n📥 Downloading extra characters (百, 千, 万, 億)...")
    for char, codepoint in EXTRA_CHARACTERS.items():
        result = download_and_process_character(char, codepoint)
        if result:
            key, data = result
            all_data[key] = data
    
    # Save to JSON
    output_path = os.path.join(OUTPUT_DIR, JSON_OUTPUT)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Saved {len(all_data)} characters to {output_path}")
    print("\n📝 Summary:")
    print(f"   Total characters: {len(all_data)}")
    print(f"   Output file: {output_path}")
    print("\n💡 Next steps:")
    print("   1. Add this JSON file to your Xcode project")
    print("   2. Make sure it's included in your target's Copy Bundle Resources")
    print("   3. Update the stroke data loader to support Chinese characters")


if __name__ == "__main__":
    main()

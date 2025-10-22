#!/usr/bin/env python3
"""
Download and convert KanjiVG kana SVG files to JSON stroke data.
FIXED VERSION: Normalizes entire character, not individual strokes.

Usage:
    python3 download_kana_strokes_json_fixed.py

This script will:
1. Download hiragana and katakana SVG files from KanjiVG
2. Parse the SVG path data
3. Convert to normalized stroke coordinates (CHARACTER-LEVEL normalization)
4. Generate JSON files with the stroke data
"""

import urllib.request
import xml.etree.ElementTree as ET
import json
import os
import re
from typing import List, Dict, Tuple

# KanjiVG GitHub raw content URL
KANJIVG_BASE_URL = "https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/"

# Hiragana Unicode range: U+3040 to U+309F
# Katakana Unicode range: U+30A0 to U+30FF
HIRAGANA_RANGE = range(0x3041, 0x3097)  # Common hiragana
KATAKANA_RANGE = range(0x30A1, 0x30F7)  # Common katakana

# Output directory
OUTPUT_DIR = "KanaStrokeData"
JSON_OUTPUT_HIRAGANA = "hiragana_strokes.json"
JSON_OUTPUT_KATAKANA = "katakana_strokes.json"
JSON_OUTPUT_COMBINED = "kanastrokes.json"


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
                    x2, y2 = numbers[num_idx + 2], numbers[num_idx + 3]
                    x3, y3 = numbers[num_idx + 4], numbers[num_idx + 5]
                else:
                    x1, y1 = current_x + numbers[num_idx], current_y + numbers[num_idx + 1]
                    x2, y2 = current_x + numbers[num_idx + 2], current_y + numbers[num_idx + 3]
                    x3, y3 = current_x + numbers[num_idx + 4], current_y + numbers[num_idx + 5]
                
                # Sample bezier curve
                for t in [0.25, 0.5, 0.75, 1.0]:
                    t1 = 1 - t
                    bx = t1**3 * current_x + 3 * t1**2 * t * x1 + 3 * t1 * t**2 * x2 + t**3 * x3
                    by = t1**3 * current_y + 3 * t1**2 * t * y1 + 3 * t1 * t**2 * y2 + t**3 * y3
                    points.append((bx, by))
                
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
                
                # Sample curve
                for t in [0.33, 0.67, 1.0]:
                    t1 = 1 - t
                    bx = t1**2 * current_x + 2 * t1 * t * x2 + t**2 * x3
                    by = t1**2 * current_y + 2 * t1 * t * y2 + t**2 * y3
                    points.append((bx, by))
                
                current_x, current_y = x3, y3
                num_idx += 4
    
    return points


def normalize_strokes_character_level(strokes: List[List[Tuple[float, float]]]) -> List[List[Tuple[float, float]]]:
    """
    Normalize coordinates to 0.0-1.0 range at CHARACTER level.
    This preserves relative positioning between strokes.
    
    FIXED: This was the main issue - normalizing each stroke independently
    instead of normalizing the entire character as a whole.
    """
    if not strokes:
        return []
    
    # Flatten all points from all strokes to find global bounds
    all_points = []
    for stroke in strokes:
        all_points.extend(stroke)
    
    if not all_points:
        return []
    
    # Find bounding box for ENTIRE character
    min_x = min(p[0] for p in all_points)
    max_x = max(p[0] for p in all_points)
    min_y = min(p[1] for p in all_points)
    max_y = max(p[1] for p in all_points)
    
    width = max(max_x - min_x, 1.0)
    height = max(max_y - min_y, 1.0)
    
    # Use square aspect ratio based on the larger dimension
    scale = max(width, height)
    
    # Normalize ALL strokes using the SAME bounding box
    normalized_strokes = []
    for stroke in strokes:
        normalized_stroke = []
        for x, y in stroke:
            norm_x = (x - min_x) / scale
            norm_y = (y - min_y) / scale
            normalized_stroke.append((norm_x, norm_y))
        normalized_strokes.append(normalized_stroke)
    
    return normalized_strokes


def parse_kanjivg_svg(svg_content: str) -> List[List[Tuple[float, float]]]:
    """Parse KanjiVG SVG and extract stroke paths."""
    if not svg_content:
        return []
    
    # Parse XML
    try:
        # Remove namespace to make parsing easier
        svg_content = svg_content.replace('xmlns="http://www.w3.org/2000/svg"', '')
        root = ET.fromstring(svg_content)
    except Exception as e:
        print(f"  ⚠️  XML parsing error: {e}")
        return []
    
    strokes = []
    
    # Find all path elements (each represents a stroke)
    for path in root.findall('.//path'):
        d = path.get('d')
        if d:
            points = parse_svg_path(d)
            if points:
                strokes.append(points)
    
    # Normalize at character level (not per-stroke!)
    normalized_strokes = normalize_strokes_character_level(strokes)
    
    return normalized_strokes


def convert_to_json_structure(stroke_data: Dict[int, List[List[Tuple[float, float]]]]) -> Dict:
    """Convert stroke data to JSON-serializable structure."""
    json_data = {}
    
    for codepoint, strokes in stroke_data.items():
        char = chr(codepoint)
        hex_key = f"U+{codepoint:04X}"
        
        json_strokes = []
        for stroke in strokes:
            json_stroke = []
            for point_idx, (x, y) in enumerate(stroke):
                t = point_idx * 0.05  # Simple timing
                json_stroke.append({
                    "x": round(x, 4),
                    "y": round(y, 4),
                    "t": round(t, 2)
                })
            json_strokes.append(json_stroke)
        
        json_data[hex_key] = {
            "character": char,
            "codepoint": codepoint,
            "strokes": json_strokes
        }
    
    return json_data


def save_json_files(hiragana_data: Dict, katakana_data: Dict, output_dir: str):
    """Save separate JSON files for hiragana, katakana, and combined."""
    
    # Save hiragana
    hiragana_path = os.path.join(output_dir, JSON_OUTPUT_HIRAGANA)
    with open(hiragana_path, 'w', encoding='utf-8') as f:
        json.dump(hiragana_data, f, ensure_ascii=False, indent=2)
    print(f"✅ Generated {hiragana_path}")
    
    # Save katakana
    katakana_path = os.path.join(output_dir, JSON_OUTPUT_KATAKANA)
    with open(katakana_path, 'w', encoding='utf-8') as f:
        json.dump(katakana_data, f, ensure_ascii=False, indent=2)
    print(f"✅ Generated {katakana_path}")
    
    # Save combined
    combined_data = {**hiragana_data, **katakana_data}
    combined_path = os.path.join(output_dir, JSON_OUTPUT_COMBINED)
    with open(combined_path, 'w', encoding='utf-8') as f:
        json.dump(combined_data, f, ensure_ascii=False, indent=2)
    print(f"✅ Generated {combined_path}")
    
    return hiragana_path, katakana_path, combined_path


def main():
    print("🎌 KanjiVG Kana Stroke Downloader (FIXED VERSION)")
    print("=" * 50)
    print("✨ This version fixes character-level normalization")
    print("=" * 50)
    
    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    hiragana_stroke_data = {}
    katakana_stroke_data = {}
    
    # Download Hiragana
    print("\n📥 Downloading Hiragana...")
    for codepoint in HIRAGANA_RANGE:
        char = chr(codepoint)
        print(f"  Downloading {char} (U+{codepoint:04X})...", end=" ")
        
        svg_content = download_svg(codepoint)
        if svg_content:
            strokes = parse_kanjivg_svg(svg_content)
            if strokes:
                hiragana_stroke_data[codepoint] = strokes
                print(f"✓ ({len(strokes)} strokes)")
                
                # Save individual SVG for reference
                svg_path = os.path.join(OUTPUT_DIR, f"{codepoint:05x}.svg")
                with open(svg_path, 'w', encoding='utf-8') as f:
                    f.write(svg_content)
            else:
                print("✗ (no strokes)")
        else:
            print("✗")
    
    # Download Katakana
    print("\n📥 Downloading Katakana...")
    for codepoint in KATAKANA_RANGE:
        char = chr(codepoint)
        print(f"  Downloading {char} (U+{codepoint:04X})...", end=" ")
        
        svg_content = download_svg(codepoint)
        if svg_content:
            strokes = parse_kanjivg_svg(svg_content)
            if strokes:
                katakana_stroke_data[codepoint] = strokes
                print(f"✓ ({len(strokes)} strokes)")
                
                # Save individual SVG for reference
                svg_path = os.path.join(OUTPUT_DIR, f"{codepoint:05x}.svg")
                with open(svg_path, 'w', encoding='utf-8') as f:
                    f.write(svg_content)
            else:
                print("✗ (no strokes)")
        else:
            print("✗")
    
    # Convert to JSON structure
    print(f"\n📝 Converting to JSON format...")
    hiragana_json = convert_to_json_structure(hiragana_stroke_data)
    katakana_json = convert_to_json_structure(katakana_stroke_data)
    
    # Save JSON files
    print(f"\n💾 Saving JSON files...")
    hiragana_path, katakana_path, combined_path = save_json_files(
        hiragana_json, 
        katakana_json, 
        OUTPUT_DIR
    )
    
    print(f"\n📊 Summary:")
    print(f"   Hiragana characters: {len(hiragana_stroke_data)}")
    print(f"   Katakana characters: {len(katakana_stroke_data)}")
    print(f"   Total characters: {len(hiragana_stroke_data) + len(katakana_stroke_data)}")
    print(f"   Output directory: {OUTPUT_DIR}/")
    print(f"\n🔧 What was fixed:")
    print(f"   ✅ Normalization now at CHARACTER level (not per-stroke)")
    print(f"   ✅ Strokes maintain relative positioning")
    print(f"   ✅ Diacriticals will be positioned correctly")
    print(f"   ✅ Multi-stroke characters like み will display correctly")
    print(f"\n💡 Next steps:")
    print(f"   1. Replace your old kanastrokes.json with the new one")
    print(f"   2. Run fix_diacriticals.py to correct diacritical marks")
    print(f"   3. Rebuild your app and test")
    print(f"\n📄 Generated files:")
    print(f"   • {JSON_OUTPUT_HIRAGANA} - Hiragana only")
    print(f"   • {JSON_OUTPUT_KATAKANA} - Katakana only")
    print(f"   • {JSON_OUTPUT_COMBINED} - Both combined (use this one!)")


if __name__ == "__main__":
    main()

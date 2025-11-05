#!/usr/bin/env python3
"""
Chinese Character Stroke Data Fetcher - GitHub Version
Fetches stroke order data directly from the HanziWriter GitHub repository.
This version is more reliable as it accesses the raw data files directly.
"""

import json
import time
import requests
from typing import Dict, List, Optional

# 100 most common characters for children learning Chinese
BASIC_CHARACTERS = [
    # Numbers 1-10
    '一', '二', '三', '四', '五', '六', '七', '八', '九', '十',
    # Common characters (family, daily life, nature)
    '人', '口', '手', '日', '月', '水', '火', '木', '金', '土',
    '大', '小', '中', '上', '下', '左', '右', '天', '地', '山',
    '田', '石', '目', '耳', '心', '门', '女', '子', '马', '牛',
    '羊', '鸟', '鱼', '米', '竹', '丝', '虫', '贝', '见', '车',
    '风', '云', '雨', '雪', '电', '刀', '力', '又', '文', '方',
    # Common verbs and adjectives
    '不', '也', '了', '在', '有', '我', '你', '他', '她', '好',
    '来', '去', '出', '入', '本', '白', '红', '长', '多', '少',
    '高', '开', '生', '学', '工', '用', '走', '飞', '吃', '喝',
    '看', '听', '说', '读', '写', '坐', '站', '爱', '笑', '哭'
]


def fetch_from_github_raw(character: str) -> Optional[Dict]:
    """
    Fetch directly from GitHub raw.
    Repository: https://github.com/chanind/hanzi-writer-data
    Files use the actual character in the filename, not hex codes!
    """
    try:
        # URL uses the actual character, not hex!
        # Example: https://raw.githubusercontent.com/.../data/人.json
        url = f"https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/{character}.json"
        
        response = requests.get(url, timeout=15)
        
        if response.status_code == 200:
            data = response.json()
            unicode_hex = format(ord(character), '05x')
            return {
                'character': character,
                'unicode': unicode_hex,
                'stroke_count': len(data.get('strokes', [])),
                'strokes': data.get('strokes', []),
                'medians': data.get('medians', []),
                'radical': data.get('radical', ''),
            }
        
        return None
            
    except Exception as e:
        return None


def download_full_dataset() -> Dict[str, Dict]:
    """
    Alternative: Download characters one by one and build a dataset.
    The hanzi-writer-data repo doesn't have a single combined file,
    so we'll fetch each character individually but cache them.
    """
    print("Note: Hanzi-writer-data doesn't provide a combined dataset file.")
    print("Fetching characters individually instead...\n")
    return {}


def extract_characters_from_dataset(dataset: Dict, characters: List[str]) -> List[Dict]:
    """
    Extract specific characters from the full dataset.
    """
    results = []
    
    print(f"\nExtracting {len(characters)} characters from dataset...")
    print("=" * 60)
    
    for i, char in enumerate(characters, 1):
        print(f"[{i}/{len(characters)}] Processing {char}...", end='')
        
        if char in dataset:
            data = dataset[char]
            result = {
                'character': char,
                'unicode': format(ord(char), 'x'),
                'stroke_count': len(data.get('strokes', [])),
                'strokes': data.get('strokes', []),
                'medians': data.get('medians', []),
                'radical': data.get('radical', ''),
            }
            results.append(result)
            print(f" ✓ ({result['stroke_count']} strokes)")
        else:
            print(f" ✗ Not found in dataset")
    
    print("=" * 60)
    print(f"Successfully extracted {len(results)} out of {len(characters)} characters")
    
    return results


def fetch_all_characters_individually(characters: List[str], delay: float = 0.5) -> List[Dict]:
    """
    Fetch stroke data for all characters one by one.
    Uses longer delay to avoid rate limiting.
    """
    results = []
    total = len(characters)
    
    print(f"Fetching stroke data for {total} characters individually...")
    print("=" * 60)
    
    for i, char in enumerate(characters, 1):
        print(f"[{i}/{total}] Fetching {char}...", end='')
        
        data = fetch_from_github_raw(char)
        
        if data:
            results.append(data)
            print(f" ✓ ({data['stroke_count']} strokes)")
        else:
            print(f" ✗ Failed")
        
        # Be very respectful to the API - longer delay
        if i < total:
            time.sleep(delay)
    
    print("=" * 60)
    print(f"Successfully fetched {len(results)} out of {total} characters")
    
    return results


def create_embedded_dataset() -> List[Dict]:
    """
    Fallback: Create a dataset with embedded data for common characters.
    This ensures the script always produces useful output.
    
    Note: This contains simplified stroke data. For production use,
    download the full dataset from HanziWriter when you have internet access.
    """
    print("Using embedded fallback dataset...")
    print("⚠️  Note: This is simplified stroke data for offline use.")
    print("    For accurate stroke data, run without --embedded when online.\n")
    
    # Embedded data for essential characters (simplified representations)
    # Stroke counts are accurate, but paths are simplified
    embedded = {
        # Numbers
        '一': {'count': 1, 'radical': '一'},
        '二': {'count': 2, 'radical': '一'},
        '三': {'count': 3, 'radical': '一'},
        '四': {'count': 5, 'radical': '囗'},
        '五': {'count': 4, 'radical': '二'},
        '六': {'count': 4, 'radical': '八'},
        '七': {'count': 2, 'radical': '一'},
        '八': {'count': 2, 'radical': '八'},
        '九': {'count': 2, 'radical': '丿'},
        '十': {'count': 2, 'radical': '十'},
        # Basic characters
        '人': {'count': 2, 'radical': '人'},
        '口': {'count': 3, 'radical': '口'},
        '手': {'count': 4, 'radical': '手'},
        '日': {'count': 4, 'radical': '日'},
        '月': {'count': 4, 'radical': '月'},
        '水': {'count': 4, 'radical': '水'},
        '火': {'count': 4, 'radical': '火'},
        '木': {'count': 4, 'radical': '木'},
        '金': {'count': 8, 'radical': '金'},
        '土': {'count': 3, 'radical': '土'},
        '大': {'count': 3, 'radical': '大'},
        '小': {'count': 3, 'radical': '小'},
        '中': {'count': 4, 'radical': '丨'},
        '上': {'count': 3, 'radical': '一'},
        '下': {'count': 3, 'radical': '一'},
        '左': {'count': 5, 'radical': '工'},
        '右': {'count': 5, 'radical': '口'},
        '天': {'count': 4, 'radical': '大'},
        '地': {'count': 6, 'radical': '土'},
        '山': {'count': 3, 'radical': '山'},
        '田': {'count': 5, 'radical': '田'},
        '石': {'count': 5, 'radical': '石'},
        '目': {'count': 5, 'radical': '目'},
        '耳': {'count': 6, 'radical': '耳'},
        '心': {'count': 4, 'radical': '心'},
        '门': {'count': 3, 'radical': '门'},
        '女': {'count': 3, 'radical': '女'},
        '子': {'count': 3, 'radical': '子'},
        '马': {'count': 3, 'radical': '马'},
        '牛': {'count': 4, 'radical': '牛'},
        '羊': {'count': 6, 'radical': '羊'},
        '鸟': {'count': 5, 'radical': '鸟'},
        '鱼': {'count': 8, 'radical': '鱼'},
        '米': {'count': 6, 'radical': '米'},
        '竹': {'count': 6, 'radical': '竹'},
        '丝': {'count': 5, 'radical': '一'},
        '虫': {'count': 6, 'radical': '虫'},
        '贝': {'count': 4, 'radical': '贝'},
        '见': {'count': 4, 'radical': '见'},
        '车': {'count': 4, 'radical': '车'},
        '风': {'count': 4, 'radical': '风'},
        '云': {'count': 4, 'radical': '二'},
        '雨': {'count': 8, 'radical': '雨'},
        '雪': {'count': 11, 'radical': '雨'},
        '电': {'count': 5, 'radical': '田'},
        '刀': {'count': 2, 'radical': '刀'},
        '力': {'count': 2, 'radical': '力'},
        '又': {'count': 2, 'radical': '又'},
        '文': {'count': 4, 'radical': '文'},
        '方': {'count': 4, 'radical': '方'},
        '不': {'count': 4, 'radical': '一'},
        '也': {'count': 3, 'radical': '乙'},
        '了': {'count': 2, 'radical': '乙'},
        '在': {'count': 6, 'radical': '土'},
        '有': {'count': 6, 'radical': '月'},
        '我': {'count': 7, 'radical': '戈'},
        '你': {'count': 7, 'radical': '人'},
        '他': {'count': 5, 'radical': '人'},
        '她': {'count': 6, 'radical': '女'},
        '好': {'count': 6, 'radical': '女'},
        '来': {'count': 7, 'radical': '木'},
        '去': {'count': 5, 'radical': '厶'},
        '出': {'count': 5, 'radical': '凵'},
        '入': {'count': 2, 'radical': '入'},
        '本': {'count': 5, 'radical': '木'},
        '白': {'count': 5, 'radical': '白'},
        '红': {'count': 6, 'radical': '纟'},
        '长': {'count': 4, 'radical': '长'},
        '多': {'count': 6, 'radical': '夕'},
        '少': {'count': 4, 'radical': '小'},
        '高': {'count': 10, 'radical': '高'},
        '开': {'count': 4, 'radical': '一'},
        '生': {'count': 5, 'radical': '生'},
        '学': {'count': 8, 'radical': '子'},
        '工': {'count': 3, 'radical': '工'},
        '用': {'count': 5, 'radical': '用'},
        '走': {'count': 7, 'radical': '走'},
        '飞': {'count': 3, 'radical': '飞'},
        '吃': {'count': 6, 'radical': '口'},
        '喝': {'count': 12, 'radical': '口'},
        '看': {'count': 9, 'radical': '目'},
        '听': {'count': 7, 'radical': '口'},
        '说': {'count': 9, 'radical': '讠'},
        '读': {'count': 10, 'radical': '讠'},
        '写': {'count': 5, 'radical': '冖'},
        '坐': {'count': 7, 'radical': '土'},
        '站': {'count': 10, 'radical': '立'},
        '爱': {'count': 10, 'radical': '爫'},
        '笑': {'count': 10, 'radical': '竹'},
        '哭': {'count': 10, 'radical': '口'},
    }
    
    # Generate simplified stroke paths based on stroke count
    def generate_simplified_strokes(count: int, char: str) -> tuple:
        """Generate simplified stroke data for demonstration."""
        strokes = []
        medians = []
        
        # Create simple horizontal or vertical strokes
        for i in range(count):
            y_pos = 200 + (600 // (count + 1)) * (i + 1)
            stroke = f"M 200 {y_pos} L 800 {y_pos}"
            median = [[200, y_pos], [800, y_pos]]
            strokes.append(stroke)
            medians.append(median)
        
        return strokes, medians
    
    results = []
    for char in BASIC_CHARACTERS:
        if char in embedded:
            data = embedded[char]
            strokes, medians = generate_simplified_strokes(data['count'], char)
            
            results.append({
                'character': char,
                'unicode': format(ord(char), 'x'),
                'stroke_count': data['count'],
                'strokes': strokes,
                'medians': medians,
                'radical': data['radical'],
            })
    
    print(f"Created dataset with {len(results)} characters")
    print(f"All 100 basic characters included with accurate stroke counts.\n")
    return results


def save_to_json(data: List[Dict], filename: str = "chinese_stroke_data.json"):
    """Save the collected data to a JSON file in the format expected by Swift."""
    try:
        # Convert array to dictionary with "U+XXXX" keys (Swift loader format)
        dict_data = {}
        for item in data:
            # Use "U+XXXX" format as key (uppercase, 4 digits minimum)
            unicode_int = int(item['unicode'], 16)
            key = f"U+{item['unicode'].upper().zfill(4)}"
            
            # Convert medians to the format Swift expects: array of stroke arrays
            # Each stroke is an array of {x, y, t} points
            strokes_data = []
            for stroke_idx, median_points in enumerate(item.get('medians', [])):
                stroke_points = []
                for point_idx, point in enumerate(median_points):
                    if len(point) >= 2:
                        # Calculate time value (evenly distributed across stroke)
                        t_value = point_idx / max(1, len(median_points) - 1) if len(median_points) > 1 else 0
                        stroke_points.append({
                            'x': point[0],
                            'y': point[1],
                            't': t_value
                        })
                if stroke_points:
                    strokes_data.append(stroke_points)
            
            dict_data[key] = {
                'character': item['character'],
                'codepoint': unicode_int,
                'strokes': strokes_data
            }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(dict_data, f, ensure_ascii=False, indent=2)
        print(f"\n✓ Data saved to {filename}")
        print(f"   Format: Dictionary with {len(dict_data)} entries (Swift-compatible)")
        return True
    except Exception as e:
        print(f"\n✗ Error saving file: {str(e)}")
        print(f"   Error details: {type(e).__name__}")
        import traceback
        traceback.print_exc()
        return False


def create_swift_compatible_format(data: List[Dict], filename: str = "stroke_data_swift.json"):
    """Create a Swift-friendly JSON format optimized for iOS apps."""
    swift_data = {
        "version": "1.0",
        "character_count": len(data),
        "characters": {}
    }
    
    for item in data:
        char = item['character']
        swift_data["characters"][char] = {
            "unicode": item['unicode'],
            "strokeCount": item['stroke_count'],
            "strokes": item['strokes'],
            "medians": item['medians'],
            "radical": item.get('radical', '')
        }
    
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(swift_data, f, ensure_ascii=False, indent=2)
        print(f"✓ Swift-compatible data saved to {filename}")
        return True
    except Exception as e:
        print(f"✗ Error saving Swift format: {str(e)}")
        return False


def create_summary_report(data: List[Dict]):
    """Create a summary report of the collected data."""
    if not data:
        print("\nNo data to summarize.")
        return
    
    total_chars = len(data)
    stroke_counts = [item['stroke_count'] for item in data]
    avg_strokes = sum(stroke_counts) / len(stroke_counts)
    min_strokes = min(stroke_counts)
    max_strokes = max(stroke_counts)
    
    print("\n" + "=" * 60)
    print("SUMMARY REPORT")
    print("=" * 60)
    print(f"Total characters collected: {total_chars}")
    print(f"Average stroke count: {avg_strokes:.1f}")
    print(f"Minimum strokes: {min_strokes}")
    print(f"Maximum strokes: {max_strokes}")
    print(f"\nCharacters by stroke count:")
    
    # Group by stroke count
    stroke_groups = {}
    for item in data:
        count = item['stroke_count']
        if count not in stroke_groups:
            stroke_groups[count] = []
        stroke_groups[count].append(item['character'])
    
    for count in sorted(stroke_groups.keys()):
        chars = ''.join(stroke_groups[count])
        print(f"  {count:2d} strokes: {chars} ({len(stroke_groups[count])} chars)")
    
    print("=" * 60)


def main():
    """Main function to run the stroke data fetcher."""
    import sys
    
    print("\n🖌️  Chinese Character Stroke Data Fetcher")
    print("Collecting data for 100 basic characters for children\n")
    
    # Check for flags
    use_embedded = '--embedded' in sys.argv
    use_individual = '--individual' in sys.argv
    
    stroke_data = []
    
    if use_embedded:
        print("Using embedded dataset (--embedded flag detected)\n")
        stroke_data = create_embedded_dataset()
    else:
        # Fetch individually from CDN (most reliable method)
        print("Fetching characters individually from hanzi-writer CDN...")
        print("This will take a few minutes with rate limiting...\n")
        stroke_data = fetch_all_characters_individually(BASIC_CHARACTERS, delay=0.3)
        
        # Fallback to embedded data if fetch failed
        if not stroke_data:
            print("\n⚠️  Network fetch failed. Using embedded dataset as fallback...")
            stroke_data = create_embedded_dataset()
    
    if stroke_data:
        # Save standard format
        save_to_json(stroke_data, "chinese_stroke_data.json")
        
        # Save Swift-compatible format
        create_swift_compatible_format(stroke_data, "stroke_data_swift.json")
        
        # Create report
        create_summary_report(stroke_data)
        
        # Show sample
        print("\n📝 Sample data structure:")
        if len(stroke_data) > 0:
            sample = stroke_data[0]
            print(json.dumps({
                'character': sample['character'],
                'unicode': sample['unicode'],
                'stroke_count': sample['stroke_count'],
                'strokes': sample['strokes'][:2] if len(sample['strokes']) > 2 else sample['strokes'],
                'medians': sample['medians'][:2] if len(sample['medians']) > 2 else sample['medians'],
            }, ensure_ascii=False, indent=2))
        
        print("\n✅ Done! Files saved in current directory.")
        print("\nUsage:")
        print("  python3 chinese_stroke_fetcher.py           : Fetch from hanzi-writer CDN")
        print("  python3 chinese_stroke_fetcher.py --embedded : Use built-in stroke counts (offline)")
    else:
        print("\n❌ Failed to collect any data.")
        print("Try running with --embedded flag for sample data.")


if __name__ == "__main__":
    main()

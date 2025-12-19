#!/usr/bin/env python3
"""
Quick test script to verify hanzi-writer-data URLs work correctly
"""

import requests

# Test characters
test_chars = {
    '人': 0x4EBA,  # person
    '水': 0x6C34,  # water
    '火': 0x706B,  # fire
    '一': 0x4E00,  # one
}

print("Testing hanzi-writer-data URLs...\n")

for char, codepoint in test_chars.items():
    unicode_hex = format(codepoint, '05x')
    # Use actual character in URL, not hex!
    url = f"https://raw.githubusercontent.com/chanind/hanzi-writer-data/refs/heads/master/data/{char}.json"
    
    print(f"Testing: {char} (U+{unicode_hex.upper()})")
    print(f"  URL: {url}")
    
    try:
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            stroke_count = len(data.get('strokes', []))
            print(f"  ✅ SUCCESS - {stroke_count} strokes")
        else:
            print(f"  ❌ FAILED - HTTP {response.status_code}")
    except Exception as e:
        print(f"  ❌ ERROR - {type(e).__name__}: {str(e)}")
    
    print()

print("\nIf all tests passed, the URLs are working correctly!")
print("You can now run: python3 chinese_stroke_fetcher.py")

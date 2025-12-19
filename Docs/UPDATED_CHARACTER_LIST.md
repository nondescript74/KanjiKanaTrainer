# Updated Chinese Numbers Character List

## The Fix: 零 instead of 〇

The download script now uses **零 (U+96F6)** for zero instead of **〇 (U+3007)** because:
1. KanjiVG has full coverage of 零
2. 零 is the authentic Chinese character for zero
3. It's what's actually used in Chinese writing

## Complete Character List (0-10)

| Number | Character | Unicode | Pinyin | Jyutping | Strokes | Meaning |
|--------|-----------|---------|--------|----------|---------|---------|
| 0 | 零 | U+96F6 | líng | ling4 | 13 | zero |
| 1 | 一 | U+4E00 | yī | ji1 | 1 | one |
| 2 | 二 | U+4E8C | èr | ji6 | 2 | two |
| 3 | 三 | U+4E09 | sān | saam1 | 3 | three |
| 4 | 四 | U+56DB | sì | sei3 | 5 | four |
| 5 | 五 | U+4E94 | wǔ | ng5 | 4 | five |
| 6 | 六 | U+516D | liù | luk6 | 4 | six |
| 7 | 七 | U+4E03 | qī | cat1 | 2 | seven |
| 8 | 八 | U+516B | bā | baat3 | 2 | eight |
| 9 | 九 | U+4E5D | jiǔ | gau2 | 2 | nine |
| 10 | 十 | U+5341 | shí | sap6 | 2 | ten |

## Bonus Characters

| Character | Unicode | Pinyin | Jyutping | Strokes | Meaning |
|-----------|---------|--------|----------|---------|---------|
| 百 | U+767E | bǎi | baak3 | 6 | hundred |
| 千 | U+5343 | qiān | cin1 | 3 | thousand |
| 万 | U+4E07 | wàn | maan6 | 3 | ten thousand |
| 億 | U+5104 | yì | jik1 | 15 | hundred million |

## Why 零 Has 13 Strokes

Unlike the simple numbers 1-10 which have 1-5 strokes, 零 is a more complex character with 13 strokes. This is historically accurate:

1. **零** is composed of the rain radical (雨) on top
2. Plus the phonetic component 令 (líng) below
3. The rain radical suggests "small drops" or "tiny amounts"
4. Together it represents the concept of "nothing" or "zero"

Don't worry - your app will teach the proper stroke order from KanjiVG!

## Learning Order Suggestion

Given the stroke complexity, consider this learning path:

### Beginner (Simple Strokes):
1. 一 (1 stroke) - one
2. 二 (2 strokes) - two
3. 三 (3 strokes) - three
4. 七 (2 strokes) - seven
5. 八 (2 strokes) - eight
6. 九 (2 strokes) - nine
7. 十 (2 strokes) - ten

### Intermediate (More Strokes):
8. 五 (4 strokes) - five
9. 六 (4 strokes) - six
10. 四 (5 strokes) - four

### Advanced:
11. 零 (13 strokes) - zero

This way learners build confidence with simple characters before tackling the more complex zero!

## Using Zero in Chinese

### Phone Numbers:
```
138-0123-4567
yāo sān bā - líng yāo èr sān - sì wǔ liù qī
```

### Decimals:
```
0.5 → 零点五 (líng diǎn wǔ)
0.25 → 零点二五 (líng diǎn èr wǔ)
```

### Years:
```
2001 → 二零零一 (èr líng líng yī) or 二千零一 (èr qiān líng yī)
2024 → 二零二四 (èr líng èr sì)
```

### Counting:
In counting, you typically start from 一 (one), not 零 (zero):
```
一、二、三、四、五...
yī, èr, sān, sì, wǔ...
```

But zero is used when needed:
```
零下五度 (líng xià wǔ dù) = below zero 5 degrees = -5°C
```

## Quick Reference Card

Print or display this for learners:

```
Chinese Numbers 0-10

零  líng   (ling4)    0
一  yī     (ji1)      1
二  èr     (ji6)      2  
三  sān    (saam1)    3
四  sì     (sei3)     4
五  wǔ     (ng5)      5
六  liù    (luk6)     6
七  qī     (cat1)     7
八  bā     (baat3)    8
九  jiǔ    (gau2)     9
十  shí    (sap6)     10

Pinyin (Mandarin) first
Jyutping (Cantonese) in parentheses
```

## Run the Updated Script

```bash
python3 download_chinese_numbers.py
```

Expected output:
```
==========================================================
Chinese Numbers Stroke Data Downloader
==========================================================

📥 Downloading basic numbers (0-10)...
Processing 零 (U+96F6)...
  ✅ Processed 零 with 13 strokes
Processing 一 (U+4E00)...
  ✅ Processed 一 with 1 strokes
...

✅ Saved 14 characters to strokedata/chinesenumbers.json

📝 Summary:
   Total characters: 14
   Output file: strokedata/chinesenumbers.json
```

All should succeed now! 🎉

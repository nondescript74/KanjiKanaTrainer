# KanjiKanaTrainer

An iOS and iPadOS app for learning to write Japanese kana and basic Chinese characters by hand, stroke by stroke.

## What it does

- **Stroke-order demos.** Each character is drawn one stroke at a time in the correct order.
- **Handwriting practice.** You write with Apple Pencil or a finger (PencilKit), and your strokes are scored against the reference strokes.
- **Sequential practice.** You work through a set of characters in order, with the demo and practice modes working together.
- **Pronunciation.** Each character can be read aloud with on-device speech (AVSpeechSynthesizer).
- **Progress tracking.** Practice results are stored locally with SwiftData.

## Character sets

- Hiragana and katakana
- 100 basic Chinese characters: numbers, nature, body parts, common nouns, verbs, pronouns and adjectives
- Chinese numbers, including compound numbers

## Tech

- Swift / SwiftUI
- PencilKit for stroke capture
- A stroke evaluator that compares your strokes with reference stroke paths
- AVSpeechSynthesizer for audio
- SwiftData for local progress, with no account and no server

## Project layout

| Path | Contents |
|---|---|
| `Domain/` | Models and view models for lessons and practice |
| `Environment/` | App environment and dependency wiring |
| `strokedata/` | Stroke data (JSON) for kana and Chinese characters |
| `Docs/` | Implementation notes and data-preparation scripts |
| `download_kana_strokes_json_fixed.py` | Builds the kana stroke file from KanjiVG |

## Third-party data

Stroke data comes from two open datasets, and those files stay under their original licenses:

- **[KanjiVG](https://kanjivg.tagaini.net)** by Ulrich Apel, licensed under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). Used for kana and Chinese numbers.
- **[hanzi-writer-data](https://github.com/chanind/hanzi-writer-data)**, derived from Make Me a Hanzi and the Arphic PL fonts. Used for Chinese characters. See that repository for its license terms.

## Status

This is a personal project in development. It is not published on the App Store.

## License

Copyright © 2025–2026 Zahirudeen Premji. All rights reserved. See [LICENSE](LICENSE). The third-party stroke data listed above is excluded.

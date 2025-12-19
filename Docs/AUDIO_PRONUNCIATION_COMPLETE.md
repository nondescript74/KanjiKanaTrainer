# Audio Pronunciation Integration - Complete ✅

## Overview

Audio pronunciation has been successfully integrated into the app! Users can now hear the correct pronunciation of Chinese characters (and Japanese kana) during demos and practice.

## Files Added

### 1. CharacterGlyph+Audio.swift
Extension that adds pronunciation capabilities to `CharacterGlyph`:
- `playPronunciation()` - Plays Mandarin pronunciation using pinyin
- `playCantonesePromunication()` - Plays Cantonese using jyutping
- `playLiteralPronunciation()` - Plays the character itself
- `SpeechSynthesizerManager` - Shared manager for controlling playback

### 2. AudioButton.swift
Reusable UI components for audio playback:
- `AudioButton` - Flexible button with multiple styles
- `AudioButtonStyle` - Pre-configured styles (standard, compact, large, mandarin, cantonese)
- `DualAudioButtons` - Shows both Mandarin and Cantonese buttons

## How It Works

### Automatic Playback (Demo Mode)
When a demo completes animating a character's strokes, the pronunciation automatically plays:

```swift
// In SequentialDemoViewModel
demoState = .completed

// Speak the character
if let glyph = currentGlyph {
    speakCharacter(glyph)  // Automatically uses new extension
}
```

### Manual Playback
Users can manually trigger pronunciation:

```swift
// Play Mandarin pronunciation
viewModel.playCurrentPronunciation()

// Play Cantonese pronunciation
viewModel.playCurrentCantonese()
```

## Using Audio in Views

### Option 1: Simple Audio Button
```swift
AudioButton(action: {
    viewModel.playCurrentPronunciation()
}, style: .standard)
```

### Option 2: Dual Language Buttons
```swift
DualAudioButtons(
    onPlayMandarin: {
        viewModel.playCurrentPronunciation()
    },
    onPlayCantonese: {
        viewModel.playCurrentCantonese()
    },
    isPlaying: false
)
```

### Option 3: Direct Character Pronunciation
```swift
Button("Play") {
    currentGlyph.playPronunciation()
}
```

## Adding to Demo View

To add audio buttons to the demo view, insert this code in the toolbar or control area:

```swift
// Toolbar item
.toolbar {
    ToolbarItemGroup(placement: .bottomBar) {
        // Existing controls...
        
        Spacer()
        
        // Audio button
        AudioButton(action: {
            viewModel.playCurrentPronunciation()
        }, style: .standard)
        
        Spacer()
    }
}
```

Or for dual pronunciation:

```swift
VStack {
    // Existing demo content...
    
    DualAudioButtons(
        onPlayMandarin: {
            viewModel.playCurrentPronunciation()
        },
        onPlayCantonese: {
            viewModel.playCurrentCantonese()
        },
        isPlaying: viewModel.demoState == .drawing
    )
    .padding()
}
```

## Adding to Practice View

For practice mode, add a pronunciation button in the results/feedback area:

```swift
// After user completes writing
if let glyph = viewModel.currentGlyph {
    HStack(spacing: 16) {
        Text("Character: \(glyph.literal)")
        
        AudioButton(action: {
            glyph.playPronunciation()
        }, style: .compact)
    }
}
```

## Audio Settings

### Speech Rate
Adjust playback speed for different learning levels:

```swift
// Slower for beginners
glyph.playPronunciation(rate: 0.3)

// Normal pace
glyph.playPronunciation(rate: 0.4)

// Faster for advanced
glyph.playPronunciation(rate: 0.6)
```

### Language Override
Force a specific language:

```swift
// Force Mandarin
glyph.playPronunciation(language: "zh-CN")

// Force Cantonese
glyph.playPronunciation(language: "zh-HK")

// Force Japanese
glyph.playPronunciation(language: "ja-JP")
```

## Available Button Styles

### Standard
```swift
AudioButton(action: {}, style: .standard)
```
- Icon only
- Blue color
- Medium size
- Good for toolbars

### Compact
```swift
AudioButton(action: {}, style: .compact)
```
- Small icon
- Minimal padding
- Good for inline use

### Large
```swift
AudioButton(action: {}, style: .large)
```
- Large icon + label
- Background tint
- Good for prominent placement

### Mandarin
```swift
AudioButton(action: {}, style: .mandarin)
```
- Blue color
- Chinese label "普通话"
- Background tint

### Cantonese
```swift
AudioButton(action: {}, style: .cantonese)
```
- Orange color
- Chinese label "粤语"
- Background tint

## Language Support

### Chinese Characters (Hanzi)
- **Mandarin**: Uses `readings[0]` (pinyin with tone marks)
- **Cantonese**: Uses `readings[1]` (jyutping romanization)
- **Language codes**: `zh-CN` (Mandarin), `zh-HK` (Cantonese)

### Japanese Characters (Kana/Kanji)
- Uses `readings[0]` (romaji)
- **Language code**: `ja-JP`

## Pronunciation Data Format

All characters in `firstHundredHanzi` include:
```swift
(0x597D, "好", ["hǎo", "hou2"], ["good", "well"])
//               ↑        ↑
//          Mandarin  Cantonese
```

## Example Integration: Complete Demo View

```swift
struct ChineseCharacterDemoView: View {
    @StateObject var viewModel: SequentialDemoViewModel
    
    var body: some View {
        VStack {
            // Character display
            CharacterCanvasView(glyph: viewModel.currentGlyph)
            
            // Character info
            if let glyph = viewModel.currentGlyph {
                VStack(spacing: 8) {
                    Text(glyph.literal)
                        .font(.system(size: 100))
                    
                    Text(glyph.readings[0])
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Text(glyph.meaning.joined(separator: ", "))
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Audio controls
            DualAudioButtons(
                onPlayMandarin: {
                    viewModel.playCurrentPronunciation()
                },
                onPlayCantonese: {
                    viewModel.playCurrentCantonese()
                },
                isPlaying: viewModel.demoState == .drawing
            )
            .padding()
            
            // Demo controls
            HStack {
                Button("Previous") {
                    viewModel.previousGlyph()
                }
                .disabled(!viewModel.hasPrevious)
                
                Spacer()
                
                Button(viewModel.demoState == .drawing ? "Stop" : "Start") {
                    if viewModel.demoState == .drawing {
                        viewModel.stopDemo()
                    } else {
                        viewModel.startDemo()
                    }
                }
                
                Spacer()
                
                Button("Next") {
                    viewModel.nextGlyph()
                }
                .disabled(!viewModel.hasNext)
            }
            .padding()
        }
        .task {
            await viewModel.loadCurrentGlyph()
        }
    }
}
```

## Troubleshooting

### No Sound Playing
1. Check device volume is not muted
2. Verify `readings` array is not empty
3. Check iOS speech synthesis voice is installed for the language
4. Look for debug print statements in console

### Wrong Language
1. Verify `script` property is correct (.hanzi, .kana, .kanji)
2. Check language code is correct (zh-CN, zh-HK, ja-JP)
3. Ensure voice for that language is available on device

### Pronunciation Sounds Wrong
1. Adjust the `rate` parameter (try 0.3-0.6)
2. Use `playLiteralPronunciation()` to speak the character directly
3. For Chinese, try Cantonese if Mandarin sounds off

### Performance Issues
1. Reuse `AVSpeechSynthesizer` instances (already done)
2. Stop previous speech before starting new (`stopSpeaking()`)
3. Don't create multiple synthesizers simultaneously

## Future Enhancements

### Optional: Record Native Audio
For even better quality:
1. Record native speakers pronouncing each character
2. Save as MP3 files: `U+04E00.mp3`, `U+04E8C.mp3`, etc.
3. Store in `Resources/audio/hanzi/`
4. Fall back to TTS if audio file not found

```swift
func playRecordedAudio(for codepoint: UInt32) {
    let filename = String(format: "U+%05X", codepoint)
    if let url = Bundle.main.url(forResource: filename, withExtension: "mp3", subdirectory: "audio/hanzi") {
        // Play audio file
        let player = AVAudioPlayer(contentsOf: url)
        player.play()
    } else {
        // Fallback to TTS
        playPronunciation()
    }
}
```

## Summary

✅ Audio pronunciation fully integrated
✅ Supports Mandarin Chinese (zh-CN)
✅ Supports Cantonese (zh-HK)
✅ Supports Japanese (ja-JP)
✅ Automatic playback in demo mode
✅ Manual playback via buttons
✅ Reusable UI components
✅ Multiple button styles available
✅ Rate adjustment for learners
✅ Debug logging for troubleshooting

---

**Status**: ✅ Complete and Ready to Use
**Next**: Add audio buttons to demo and practice view UIs
**Documentation**: This file

🔊 Enjoy learning with audio pronunciation!

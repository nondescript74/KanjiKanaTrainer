# Adding First 100 Characters to Demo & Practice Modes

## Quick Integration Guide

This guide shows you how to add the new "First 100 Chinese Characters" set to your existing demo and practice mode selectors.

## Step 1: Add to SequentialDemoViewModel.swift

Add these factory methods to create demo sessions for the first 100 characters:

```swift
// MARK: - First 100 Chinese Characters Factory Methods

/// First 100 Chinese Characters - Complete Set
static func firstHundredChinese(env: AppEnvironment) -> SequentialDemoViewModel {
    // Get all 99 unique characters from the first hundred set
    let characters: [CharacterID] = [
        // Numbers 1-10
        CharacterID(script: .hanzi, codepoint: 0x4E00),  // 一
        CharacterID(script: .hanzi, codepoint: 0x4E8C),  // 二
        CharacterID(script: .hanzi, codepoint: 0x4E09),  // 三
        CharacterID(script: .hanzi, codepoint: 0x56DB),  // 四
        CharacterID(script: .hanzi, codepoint: 0x4E94),  // 五
        CharacterID(script: .hanzi, codepoint: 0x516D),  // 六
        CharacterID(script: .hanzi, codepoint: 0x4E03),  // 七
        CharacterID(script: .hanzi, codepoint: 0x516B),  // 八
        CharacterID(script: .hanzi, codepoint: 0x4E5D),  // 九
        CharacterID(script: .hanzi, codepoint: 0x5341),  // 十
        
        // Column 1 continuation
        CharacterID(script: .hanzi, codepoint: 0x65E5),  // 日
        CharacterID(script: .hanzi, codepoint: 0x6708),  // 月
        CharacterID(script: .hanzi, codepoint: 0x597D),  // 好
        CharacterID(script: .hanzi, codepoint: 0x9752),  // 青
        CharacterID(script: .hanzi, codepoint: 0x8BF7),  // 请
        CharacterID(script: .hanzi, codepoint: 0x8D35),  // 贵
        CharacterID(script: .hanzi, codepoint: 0x5174),  // 兴
        CharacterID(script: .hanzi, codepoint: 0x4ED6),  // 他
        CharacterID(script: .hanzi, codepoint: 0x600E),  // 怎
        CharacterID(script: .hanzi, codepoint: 0x53EB),  // 叫
        CharacterID(script: .hanzi, codepoint: 0x4EC0),  // 什
        CharacterID(script: .hanzi, codepoint: 0x4E48),  // 么
        CharacterID(script: .hanzi, codepoint: 0x540D),  // 名
        CharacterID(script: .hanzi, codepoint: 0x5B57),  // 字
        CharacterID(script: .hanzi, codepoint: 0x6211),  // 我
        CharacterID(script: .hanzi, codepoint: 0x5927),  // 大
        CharacterID(script: .hanzi, codepoint: 0x5B66),  // 学
        CharacterID(script: .hanzi, codepoint: 0x4E2D),  // 中
        CharacterID(script: .hanzi, codepoint: 0x8001),  // 老
        CharacterID(script: .hanzi, codepoint: 0x5E08),  // 师
        CharacterID(script: .hanzi, codepoint: 0x7236),  // 父
        CharacterID(script: .hanzi, codepoint: 0x6BCD),  // 母
        CharacterID(script: .hanzi, codepoint: 0x6587),  // 文
        
        // Column 2
        CharacterID(script: .hanzi, codepoint: 0x5E02),  // 市
        CharacterID(script: .hanzi, codepoint: 0x540C),  // 同
        CharacterID(script: .hanzi, codepoint: 0x6821),  // 校
        CharacterID(script: .hanzi, codepoint: 0x5C0F),  // 小
        CharacterID(script: .hanzi, codepoint: 0x6709),  // 有
        CharacterID(script: .hanzi, codepoint: 0x670B),  // 朋
        CharacterID(script: .hanzi, codepoint: 0x53CB),  // 友
        CharacterID(script: .hanzi, codepoint: 0x95E8),  // 门
        CharacterID(script: .hanzi, codepoint: 0x95EE),  // 问
        CharacterID(script: .hanzi, codepoint: 0x8C22),  // 谢
        CharacterID(script: .hanzi, codepoint: 0x518D),  // 再
        CharacterID(script: .hanzi, codepoint: 0x89C1),  // 见
        CharacterID(script: .hanzi, codepoint: 0x56FD),  // 国
        CharacterID(script: .hanzi, codepoint: 0x4EBA),  // 人
        CharacterID(script: .hanzi, codepoint: 0x9A6C),  // 马
        CharacterID(script: .hanzi, codepoint: 0x4E5F),  // 也
        CharacterID(script: .hanzi, codepoint: 0x4E0D),  // 不
        CharacterID(script: .hanzi, codepoint: 0x8BFB),  // 读
        CharacterID(script: .hanzi, codepoint: 0x5F97),  // 得
        CharacterID(script: .hanzi, codepoint: 0x4ECB),  // 介
        CharacterID(script: .hanzi, codepoint: 0x7ECD),  // 绍
        CharacterID(script: .hanzi, codepoint: 0x4F1F),  // 伟
        CharacterID(script: .hanzi, codepoint: 0x5F1F),  // 弟
        CharacterID(script: .hanzi, codepoint: 0x59B9),  // 妹
        CharacterID(script: .hanzi, codepoint: 0x4F4F),  // 住
        CharacterID(script: .hanzi, codepoint: 0x5728),  // 在
        CharacterID(script: .hanzi, codepoint: 0x54EA),  // 哪
        CharacterID(script: .hanzi, codepoint: 0x5973),  // 女
        CharacterID(script: .hanzi, codepoint: 0x513F),  // 儿
        CharacterID(script: .hanzi, codepoint: 0x5B50),  // 子
        CharacterID(script: .hanzi, codepoint: 0x6D6A),  // 浪
        CharacterID(script: .hanzi, codepoint: 0x6CA1),  // 没
        CharacterID(script: .hanzi, codepoint: 0x4F5C),  // 作
        
        // Column 3
        CharacterID(script: .hanzi, codepoint: 0x4E8B),  // 事
        CharacterID(script: .hanzi, codepoint: 0x51C9),  // 凉
        CharacterID(script: .hanzi, codepoint: 0x95F2),  // 闲
        CharacterID(script: .hanzi, codepoint: 0x4F2F),  // 伯
        CharacterID(script: .hanzi, codepoint: 0x591A),  // 多
        CharacterID(script: .hanzi, codepoint: 0x5C11),  // 少
        CharacterID(script: .hanzi, codepoint: 0x4E24),  // 两
        CharacterID(script: .hanzi, codepoint: 0x4ECA),  // 今
        CharacterID(script: .hanzi, codepoint: 0x5929),  // 天
        CharacterID(script: .hanzi, codepoint: 0x660E),  // 明
        CharacterID(script: .hanzi, codepoint: 0x5E74),  // 年
        CharacterID(script: .hanzi, codepoint: 0x661F),  // 星
        CharacterID(script: .hanzi, codepoint: 0x671F),  // 期
        CharacterID(script: .hanzi, codepoint: 0x8349),  // 草
        CharacterID(script: .hanzi, codepoint: 0x4E0A),  // 上
        CharacterID(script: .hanzi, codepoint: 0x4E0B),  // 下
        CharacterID(script: .hanzi, codepoint: 0x5348),  // 午
        CharacterID(script: .hanzi, codepoint: 0x5403),  // 吃
        CharacterID(script: .hanzi, codepoint: 0x665A),  // 晚
        CharacterID(script: .hanzi, codepoint: 0x996D),  // 饭
        CharacterID(script: .hanzi, codepoint: 0x4E86),  // 了
        CharacterID(script: .hanzi, codepoint: 0x5462),  // 呢
        CharacterID(script: .hanzi, codepoint: 0x5427),  // 吧
        CharacterID(script: .hanzi, codepoint: 0x548C),  // 和
        CharacterID(script: .hanzi, codepoint: 0x5F88),  // 很
        CharacterID(script: .hanzi, codepoint: 0x559D),  // 喝
        CharacterID(script: .hanzi, codepoint: 0x8FD9),  // 这
        CharacterID(script: .hanzi, codepoint: 0x90A3),  // 那
        CharacterID(script: .hanzi, codepoint: 0x52AA),  // 努
        CharacterID(script: .hanzi, codepoint: 0x529B),  // 力
        CharacterID(script: .hanzi, codepoint: 0x6D77),  // 海
        CharacterID(script: .hanzi, codepoint: 0x53EF),  // 可
        CharacterID(script: .hanzi, codepoint: 0x4E50),  // 乐
    ]
    
    return SequentialDemoViewModel(
        env: env,
        characters: characters,
        title: "First 100 Chinese Characters"
    )
}

/// Greetings & Basic Conversations (from First 100)
static func firstHundredGreetings(env: AppEnvironment) -> SequentialDemoViewModel {
    let characters: [CharacterID] = [
        CharacterID(script: .hanzi, codepoint: 0x597D),  // 好
        CharacterID(script: .hanzi, codepoint: 0x8BF7),  // 请
        CharacterID(script: .hanzi, codepoint: 0x8C22),  // 谢
        CharacterID(script: .hanzi, codepoint: 0x518D),  // 再
        CharacterID(script: .hanzi, codepoint: 0x89C1),  // 见
        CharacterID(script: .hanzi, codepoint: 0x95EE),  // 问
    ]
    return SequentialDemoViewModel(env: env, characters: characters, title: "Greetings")
}

/// Self-Introduction (from First 100)
static func firstHundredIntroduction(env: AppEnvironment) -> SequentialDemoViewModel {
    let characters: [CharacterID] = [
        CharacterID(script: .hanzi, codepoint: 0x6211),  // 我
        CharacterID(script: .hanzi, codepoint: 0x53EB),  // 叫
        CharacterID(script: .hanzi, codepoint: 0x540D),  // 名
        CharacterID(script: .hanzi, codepoint: 0x5B57),  // 字
        CharacterID(script: .hanzi, codepoint: 0x4ED6),  // 他
        CharacterID(script: .hanzi, codepoint: 0x4EC0),  // 什
        CharacterID(script: .hanzi, codepoint: 0x4E48),  // 么
    ]
    return SequentialDemoViewModel(env: env, characters: characters, title: "Introduction")
}

/// Family Members (from First 100)
static func firstHundredFamily(env: AppEnvironment) -> SequentialDemoViewModel {
    let characters: [CharacterID] = [
        CharacterID(script: .hanzi, codepoint: 0x7236),  // 父
        CharacterID(script: .hanzi, codepoint: 0x6BCD),  // 母
        CharacterID(script: .hanzi, codepoint: 0x5F1F),  // 弟
        CharacterID(script: .hanzi, codepoint: 0x59B9),  // 妹
        CharacterID(script: .hanzi, codepoint: 0x5973),  // 女
        CharacterID(script: .hanzi, codepoint: 0x513F),  // 儿
        CharacterID(script: .hanzi, codepoint: 0x5B50),  // 子
    ]
    return SequentialDemoViewModel(env: env, characters: characters, title: "Family")
}

/// Time Expressions (from First 100)
static func firstHundredTime(env: AppEnvironment) -> SequentialDemoViewModel {
    let characters: [CharacterID] = [
        CharacterID(script: .hanzi, codepoint: 0x4ECA),  // 今
        CharacterID(script: .hanzi, codepoint: 0x5929),  // 天
        CharacterID(script: .hanzi, codepoint: 0x660E),  // 明
        CharacterID(script: .hanzi, codepoint: 0x5E74),  // 年
        CharacterID(script: .hanzi, codepoint: 0x6708),  // 月
        CharacterID(script: .hanzi, codepoint: 0x65E5),  // 日
        CharacterID(script: .hanzi, codepoint: 0x661F),  // 星
        CharacterID(script: .hanzi, codepoint: 0x671F),  // 期
        CharacterID(script: .hanzi, codepoint: 0x4E0A),  // 上
        CharacterID(script: .hanzi, codepoint: 0x4E0B),  // 下
        CharacterID(script: .hanzi, codepoint: 0x5348),  // 午
    ]
    return SequentialDemoViewModel(env: env, characters: characters, title: "Time")
}

/// School & Learning (from First 100)
static func firstHundredSchool(env: AppEnvironment) -> SequentialDemoViewModel {
    let characters: [CharacterID] = [
        CharacterID(script: .hanzi, codepoint: 0x5927),  // 大
        CharacterID(script: .hanzi, codepoint: 0x5C0F),  // 小
        CharacterID(script: .hanzi, codepoint: 0x5B66),  // 学
        CharacterID(script: .hanzi, codepoint: 0x6821),  // 校
        CharacterID(script: .hanzi, codepoint: 0x4E2D),  // 中
        CharacterID(script: .hanzi, codepoint: 0x8001),  // 老
        CharacterID(script: .hanzi, codepoint: 0x5E08),  // 师
        CharacterID(script: .hanzi, codepoint: 0x540C),  // 同
        CharacterID(script: .hanzi, codepoint: 0x8BFB),  // 读
    ]
    return SequentialDemoViewModel(env: env, characters: characters, title: "School")
}

/// Food & Meals (from First 100)
static func firstHundredFood(env: AppEnvironment) -> SequentialDemoViewModel {
    let characters: [CharacterID] = [
        CharacterID(script: .hanzi, codepoint: 0x5403),  // 吃
        CharacterID(script: .hanzi, codepoint: 0x559D),  // 喝
        CharacterID(script: .hanzi, codepoint: 0x996D),  // 饭
        CharacterID(script: .hanzi, codepoint: 0x665A),  // 晚
    ]
    return SequentialDemoViewModel(env: env, characters: characters, title: "Food & Meals")
}
```

## Step 2: Add to SequentialPracticeViewModel.swift

Add the same factory methods for practice mode (just change `SequentialDemoViewModel` to `SequentialPracticeViewModel`).

## Step 3: Update ChineseDemoSetSelector.swift

Add the new sets to the demo selector:

```swift
enum DemoSet: String, CaseIterable, Identifiable {
    // Existing cases...
    case numbers1to10 = "1-10"
    case bodyParts = "body"
    // ... other existing cases ...
    
    // NEW: First 100 Character sets
    case first100All = "first100all"
    case first100Greetings = "first100greet"
    case first100Introduction = "first100intro"
    case first100Family = "first100family"
    case first100Time = "first100time"
    case first100School = "first100school"
    case first100Food = "first100food"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        // ... existing cases ...
        case .first100All: return "First 100 Characters (Complete)"
        case .first100Greetings: return "Greetings & Politeness"
        case .first100Introduction: return "Self-Introduction"
        case .first100Family: return "Family Members"
        case .first100Time: return "Time Expressions"
        case .first100School: return "School & Learning"
        case .first100Food: return "Food & Meals"
        }
    }
    
    var description: String {
        switch self {
        // ... existing cases ...
        case .first100All: return "Complete beginner set of 100 essential characters"
        case .first100Greetings: return "好, 请, 谢, 再见, 问"
        case .first100Introduction: return "我, 叫, 名字, 他, 什么"
        case .first100Family: return "父, 母, 弟, 妹, 女儿, 子"
        case .first100Time: return "今天, 明天, 星期, 上午, 下午"
        case .first100School: return "大学, 小学, 学校, 老师, 同学"
        case .first100Food: return "吃, 喝, 饭, 晚饭"
        }
    }
    
    var icon: String {
        switch self {
        // ... existing cases ...
        case .first100All: return "star.circle.fill"
        case .first100Greetings: return "hand.wave.fill"
        case .first100Introduction: return "person.badge.plus"
        case .first100Family: return "person.3.fill"
        case .first100Time: return "clock.fill"
        case .first100School: return "building.2.fill"
        case .first100Food: return "fork.knife"
        }
    }
    
    var characterCount: Int {
        switch self {
        // ... existing cases ...
        case .first100All: return 99
        case .first100Greetings: return 6
        case .first100Introduction: return 7
        case .first100Family: return 7
        case .first100Time: return 11
        case .first100School: return 9
        case .first100Food: return 4
        }
    }
    
    func createViewModel(env: AppEnvironment) -> SequentialDemoViewModel {
        switch self {
        // ... existing cases ...
        case .first100All: return .firstHundredChinese(env: env)
        case .first100Greetings: return .firstHundredGreetings(env: env)
        case .first100Introduction: return .firstHundredIntroduction(env: env)
        case .first100Family: return .firstHundredFamily(env: env)
        case .first100Time: return .firstHundredTime(env: env)
        case .first100School: return .firstHundredSchool(env: env)
        case .first100Food: return .firstHundredFood(env: env)
        }
    }
}
```

Then add a new section to the body:

```swift
Section("First 100 Beginner Characters") {
    NavigationLink {
        SequentialDemoView(viewModel: DemoSet.first100All.createViewModel(env: env))
    } label: {
        ChineseDemoSetRow(set: .first100All)
    }
    
    NavigationLink {
        SequentialDemoView(viewModel: DemoSet.first100Greetings.createViewModel(env: env))
    } label: {
        ChineseDemoSetRow(set: .first100Greetings)
    }
    
    NavigationLink {
        SequentialDemoView(viewModel: DemoSet.first100Introduction.createViewModel(env: env))
    } label: {
        ChineseDemoSetRow(set: .first100Introduction)
    }
    
    NavigationLink {
        SequentialDemoView(viewModel: DemoSet.first100Family.createViewModel(env: env))
    } label: {
        ChineseDemoSetRow(set: .first100Family)
    }
    
    NavigationLink {
        SequentialDemoView(viewModel: DemoSet.first100Time.createViewModel(env: env))
    } label: {
        ChineseDemoSetRow(set: .first100Time)
    }
    
    NavigationLink {
        SequentialDemoView(viewModel: DemoSet.first100School.createViewModel(env: env))
    } label: {
        ChineseDemoSetRow(set: .first100School)
    }
    
    NavigationLink {
        SequentialDemoView(viewModel: DemoSet.first100Food.createViewModel(env: env))
    } label: {
        ChineseDemoSetRow(set: .first100Food)
    }
}
```

## Step 4: Update ChineseNumberSetSelector.swift

Similar updates for practice mode - add the same cases and navigation links.

## Step 5: Add Audio Playback (Optional)

Add this extension to play character pronunciations:

```swift
import AVFoundation

extension CharacterGlyph {
    /// Play the pronunciation of this character using iOS text-to-speech
    func playPronunciation(language: String = "zh-CN", rate: Float = 0.4) {
        guard !readings.isEmpty else {
            print("⚠️ No pronunciation available for \(literal)")
            return
        }
        
        let synthesizer = AVSpeechSynthesizer()
        let pinyin = readings[0] // First reading is always Mandarin pinyin
        let utterance = AVSpeechUtterance(string: pinyin)
        
        // Configure voice
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        // Slow down for learners
        utterance.rate = rate
        
        // Optional: adjust pitch
        utterance.pitchMultiplier = 1.0
        
        // Optional: add pre-utterance delay
        utterance.preUtteranceDelay = 0.1
        
        #if DEBUG
        print("🔊 Playing pronunciation: \(pinyin) for character: \(literal)")
        #endif
        
        synthesizer.speak(utterance)
    }
    
    /// Play the Cantonese pronunciation
    func playCantonesePromunication() {
        guard readings.count >= 2 else {
            print("⚠️ No Cantonese pronunciation available for \(literal)")
            return
        }
        
        playPronunciation(language: "zh-HK", rate: 0.4)
    }
}
```

Then in your demo view, add a play button:

```swift
Button {
    currentGlyph.playPronunciation()
} label: {
    Image(systemName: "speaker.wave.2.fill")
        .font(.title2)
}
```

## Step 6: Test the Integration

1. Build and run the app
2. Navigate to **Chinese Character Demos**
3. Look for the new **"First 100 Beginner Characters"** section
4. Select "First 100 Characters (Complete)" to see all 99 characters
5. Test the themed subsets (Greetings, Introduction, etc.)
6. Try the practice mode as well

## Expected Results

✅ New section appears in demo selector
✅ All 99 characters load successfully
✅ Stroke data displays correctly
✅ Pronunciations are available (Pinyin + Jyutping)
✅ English meanings show properly
✅ Practice mode works identically

## Troubleshooting

### Characters not loading?
- Check that `ChineseStrokeDataLoader` has the stroke data
- Verify codepoints match between repository and JSON file
- Check console for error messages

### Pronunciations not working?
- Ensure iOS speech synthesis is enabled
- Check language pack is installed (`zh-CN`)
- Verify `readings` array is not empty

### Stroke data missing?
- Confirm `chinese_stroke_data.json` includes all codepoints
- Check JSON uses either `U+04EBA` or `U+4EBA` format
- Verify `ChineseStrokeDataLoader` handles both formats

## Summary

After completing these steps, you'll have:
- ✅ Complete "First 100 Characters" set available
- ✅ 6 themed subsets for progressive learning
- ✅ Both demo and practice modes
- ✅ Audio pronunciation (optional)
- ✅ Consistent UI with existing features

---

**Time to complete**: 15-30 minutes
**Difficulty**: Easy to Medium
**Files to modify**: 4 (2 ViewModels + 2 Selectors)

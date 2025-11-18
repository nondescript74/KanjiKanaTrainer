# KanjiKanaTrainer Project Hierarchy

## App Entry Point

```
KanjiKanaTrainerApp (@main)
├── StateObject: AppEnvironment
└── Body: WindowGroup
    └── LicenseGateView
        └── RootView (main content)
```

## Core Architecture

### 1. App Environment (`AppEnvironment.swift`)
```
@MainActor class AppEnvironment: ObservableObject
├── glyphs: GlyphRepository
├── progress: ProgressRepository
├── evaluator: AttemptEvaluator
└── static func live() -> AppEnvironment
```

### 2. Data Layer

#### Glyph Repository (`GlyphRepository.swift`)
```
protocol GlyphRepository
└── func glyph(for id: CharacterID) async throws -> CharacterGlyph
└── func hasStrokeData(for codepoint: UInt32) -> Bool

struct GlyphBundleRepository: GlyphRepository
├── private static let hanzi: [UInt32: (...)]
│   ├── Numbers 0-10
│   ├── Large numbers (百, 千, 万, 億)
│   └── 100 common characters
├── private static let hiragana: [UInt32: (...)]
│   └── 46 basic hiragana characters
└── private static let katakana: [UInt32: (...)]
    └── 46 basic katakana characters
```

#### Stroke Evaluator (`StrokeEvaluator.swift`)
```
protocol AttemptEvaluator
└── func evaluate(user: [StrokePath], ideal: [StrokePath]) -> PracticeScore

struct DefaultAttemptEvaluator: AttemptEvaluator
└── Calculates orderAccuracy and shapeSimilarity
```

#### Progress Repository (Referenced but not shown)
```
protocol ProgressRepository

struct SwiftDataProgressStore: ProgressRepository
└── (SwiftData implementation)
```

## Main Navigation Structure

### Root View (`RootView.swift`)
```
struct RootView: View
├── State: AppEnvironment
├── State: selectedScript (KanaScript)
│
├── enum KanaScript
│   ├── .hiragana
│   ├── .katakana
│   └── .chineseNumbers
│
├── Quick Actions Grid:
│   ├── Demo → LessonViewLoader
│   ├── Practice → PracticeViewLoader
│   ├── Sequential Demo → DemoSetSelector / ChineseNumberDemoSelector
│   └── Sequential Practice → KanaSetSelector / ChineseNumberSetSelector
│
├── struct QuickActionCard: View
├── struct CardButtonStyle: ButtonStyle
├── struct LessonViewLoader: View
├── struct PracticeViewLoader: View
├── struct ActionButton: View
└── struct InfoCard: View
```

## License System

### License Gate (`LicenseGateView.swift`)
```
struct LicenseGateView<Content: View>: View
├── StateObject: LicenseAcceptanceViewModel
├── State: hasAcceptedLicense
└── Conditionally shows:
    ├── LicenseAcceptanceView (if not accepted)
    └── Content (main app)
```

### License Acceptance (`LicenseAcceptanceView.swift`)
```
struct LicenseAcceptanceView: View
├── StateObject: LicenseAcceptanceViewModel
├── State: showDeclineAlert
├── State: contentHeight
├── State: scrollOffset
│
├── Properties:
│   ├── onAccept: () -> Void
│   └── onDecline: (() -> Void)?
│
├── Subviews:
│   ├── headerView
│   ├── ScrollView (license text)
│   └── actionButtons
│
└── Supporting Types:
    ├── struct ContentHeightPreferenceKey: PreferenceKey
    ├── struct ScrollOffsetPreferenceKey: PreferenceKey
    └── class LicenseAcceptanceViewModel: ObservableObject
        ├── @Published needsLicenseAcceptance: Bool
        ├── @Published licenseText: String
        ├── func markAsAccepted()
        └── private func loadLicenseText()
```

## Practice Features

### 1. Single Character Practice

#### Practice View (`PracticeView.swift`)
```
struct PracticeView: View
├── StateObject: PracticeViewModel
├── State: drawing (PKDrawing)
│
├── UI Components:
│   ├── Character display (literal + meaning)
│   ├── CanvasRepresentable (drawing area)
│   ├── Clear button
│   ├── Evaluate button
│   └── Score display
│
└── class PracticeViewModel: ObservableObject
    ├── glyph: CharacterGlyph
    ├── @Published score: PracticeScore?
    ├── private let env: AppEnvironment
    │
    ├── func evaluate(_ drawing: PKDrawing)
    └── func clearScore()
```

### 2. Sequential Practice

#### Sequential Practice View (`SequentialPracticeView.swift`)
```
struct SequentialPracticeView: View
├── StateObject: SequentialPracticeViewModel
├── State: drawing (PKDrawing)
├── AppStorage: hasSeenPracticeHelp
├── State: showFirstTimeHelp
├── State: showEvaluationTip
├── State: showNavigationTip
│
└── UI Components:
    ├── Progress indicator (X of Y)
    ├── InlineTip (contextual tips)
    ├── Character display
    ├── CanvasRepresentable
    ├── Clear & Evaluate buttons
    ├── Score display
    ├── Navigation (Previous/Next/Complete)
    ├── Help button (toolbar)
    └── PracticeOverlay (first-time help)
```

#### Sequential Practice ViewModel (`SequentialPracticeViewModel.swift`)
```
@MainActor class SequentialPracticeViewModel: ObservableObject
├── @Published currentGlyph: CharacterGlyph?
├── @Published score: PracticeScore?
├── @Published isLoading: Bool
├── @Published error: Error?
├── @Published currentIndex: Int
│
├── Properties:
│   ├── private let characterIDs: [CharacterID]
│   ├── private let env: AppEnvironment
│   ├── hasNext: Bool
│   ├── hasPrevious: Bool
│   ├── currentNumber: Int
│   └── totalCount: Int
│
├── Methods:
│   ├── func loadCurrentGlyph() async
│   ├── func nextGlyph() async
│   ├── func previousGlyph() async
│   ├── func evaluate(_ drawing: PKDrawing)
│   └── func clearScore()
│
└── Static Factory Methods:
    ├── Hiragana sets (vowels, k-row, s-row, t-row, etc.)
    ├── Katakana sets (vowels, k-row, s-row, t-row, etc.)
    └── Chinese sets (0-10, 1-10, 11-19, 20-30, etc.)
```

#### Sequential Practice Help (`SequentialPracticeHelp.swift`)
```
struct SequentialPracticeHelp
│
├── struct SetSelectorBanner: View
│   ├── scriptName: String
│   ├── AppStorage: hasSeenSequentialPracticeHelp
│   ├── State: isExpanded
│   │
│   └── Subviews:
│       ├── HelpRow (multiple)
│       └── "Got it!" / "Show Help" button
│
├── struct HelpRow: View
│   ├── icon: String
│   └── text: String
│
├── struct PracticeOverlay: View
│   ├── AppStorage: hasSeenHelp
│   ├── Binding: isPresented
│   │
│   └── Full-screen help overlay
│       ├── TutorialStep (4 steps)
│       └── "Start Practicing" button
│
├── struct TutorialStep: View
│   ├── number: Int
│   └── text: String
│
├── struct InlineTip: View
│   ├── icon: String
│   ├── message: String
│   ├── color: Color
│   ├── Binding: isVisible
│   └── Dismissible inline help
│
└── struct TooltipModifier: ViewModifier
    ├── text: String
    ├── State: showTooltip
    └── Shows on long press

extension View
└── func practiceTooltip(_ text: String) -> some View
```

### 3. Set Selectors

#### Kana Set Selector (`KanaSetSelector.swift`)
```
struct KanaSetSelector: View
├── env: AppEnvironment
├── script: RootView.KanaScript
│
├── enum KanaSet: String, CaseIterable, Identifiable
│   ├── .vowels
│   ├── .kRow, .sRow, .tRow
│   ├── .nRow, .hRow, .mRow
│   ├── .yRow, .rRow, .wRow
│   └── .complete
│   │
│   ├── Properties:
│   │   ├── id: String
│   │   ├── func title(isHiragana: Bool) -> String
│   │   ├── func description(isHiragana: Bool) -> String
│   │   ├── icon: String
│   │   └── characterCount: Int
│   │
│   └── func createViewModel(env, isHiragana) -> SequentialPracticeViewModel
│
└── Body: List with sections
    ├── SetSelectorBanner (help)
    ├── NavigationLinks to SequentialPracticeView
    └── KanaSetRow for each set

struct KanaSetRow: View
├── set: KanaSetSelector.KanaSet
└── isHiragana: Bool
```

#### Chinese Number Set Selector (`ChineseNumberSetSelector.swift`)
```
struct ChineseNumberSetSelector: View
├── env: AppEnvironment
│
├── enum NumberSet: String, CaseIterable, Identifiable
│   ├── .numbers0to10, .numbers1to10
│   ├── .numbers11to19, .numbers20to30
│   ├── .numbers1to30, .largeNumbers
│   ├── .bodyParts, .nature, .sizeDirection
│   ├── .objects, .pronouns, .verbs
│   ├── .commonWords, .all100
│   │
│   ├── Properties:
│   │   ├── id: String
│   │   ├── title: String
│   │   ├── description: String
│   │   ├── icon: String
│   │   └── characterCount: Int
│   │
│   └── func createViewModel(env) -> SequentialPracticeViewModel
│
└── Body: List with sections
    ├── SetSelectorBanner (help)
    ├── NavigationLinks to SequentialPracticeView
    └── NumberSetRow for each set

struct NumberSetRow: View
└── set: ChineseNumberSetSelector.NumberSet
```

## Demo Features

### 1. Single Character Demo

#### Lesson View (`LessonView.swift`)
```
struct LessonView: View
├── StateObject: LessonViewModel
├── State: debugMessage (DEBUG only)
├── State: showDebugAlert (DEBUG only)
│
├── Configuration:
│   ├── brushColor: Color
│   ├── activeBrushColor: Color
│   ├── brushLineWidth: CGFloat
│   └── showDebugBounds: Bool
│
├── UI Components:
│   ├── Character header (literal + meaning + readings)
│   ├── Demo canvas (animated stroke drawing)
│   ├── Control buttons (Play/Pause, Restart, Speed)
│   └── Navigation buttons (Previous/Next character)
│
└── class LessonViewModel: ObservableObject
    ├── @Published glyph: CharacterGlyph?
    ├── @Published demoState: DemoState
    ├── @Published animationSpeed: AnimationSpeed
    ├── private var currentStrokeIndex: Int
    ├── private var pointsDrawn: Int
    │
    ├── enum DemoState: Equatable
    │   ├── idle
    │   ├── playing
    │   └── paused
    │
    ├── enum AnimationSpeed: String, CaseIterable
    │   ├── slow (0.015)
    │   ├── normal (0.01)
    │   └── fast (0.005)
    │
    └── Methods:
        ├── func play()
        ├── func pause()
        ├── func restart()
        ├── func nextStroke()
        └── func changeSpeed(_ speed: AnimationSpeed)
```

### 2. Sequential Demo

#### Sequential Demo View (`SequentialDemoView.swift`)
```
struct SequentialDemoView: View
├── StateObject: SequentialDemoViewModel
├── State: showHelp
│
├── UI Components:
│   ├── progressBar
│   ├── characterHeader(glyph:)
│   ├── demoCanvas(glyph:)
│   ├── controlButtons
│   ├── navigationButtons
│   └── errorView(error:)
│
└── class SequentialDemoViewModel: ObservableObject
    ├── @Published currentGlyph: CharacterGlyph?
    ├── @Published isLoading: Bool
    ├── @Published error: Error?
    ├── @Published demoState: DemoState
    ├── @Published currentStrokeIndex: Int
    ├── @Published currentIndex: Int
    │
    ├── Properties:
    │   ├── private let characterIDs: [CharacterID]
    │   ├── private let env: AppEnvironment
    │   ├── hasNext: Bool
    │   ├── hasPrevious: Bool
    │   ├── currentNumber: Int
    │   └── totalCount: Int
    │
    ├── Methods:
    │   ├── func loadCurrentGlyph() async
    │   ├── func nextGlyph() async
    │   ├── func previousGlyph() async
    │   ├── func play()
    │   ├── func pause()
    │   └── func restart()
    │
    └── Static Factory Methods:
        ├── Hiragana sets (vowels, complete)
        ├── Katakana sets (vowels, complete)
        └── Chinese sets (0-10, 1-10, etc.)
```

#### Demo Set Selector (`DemoSetSelector.swift`)
```
struct DemoSetSelector: View
├── env: AppEnvironment
├── script: RootView.KanaScript
│
├── enum DemoSet: String, CaseIterable, Identifiable
│   ├── .vowels
│   └── .complete
│   │
│   ├── Properties & Methods similar to KanaSet
│   │
│   └── func createViewModel(env, isHiragana) -> SequentialDemoViewModel
│
└── Body: List with NavigationLinks
    └── DemoSetRow for each set

struct DemoSetRow: View
├── set: DemoSetSelector.DemoSet
└── isHiragana: Bool
```

## Shared Components

### Canvas Representable (`CanvasRepresentable.swift`)
```
struct CanvasRepresentable: UIViewRepresentable
├── Binding: drawing (PKDrawing)
│
├── func makeCoordinator() -> Coordinator
├── func makeUIView(context:) -> PKCanvasView
└── func updateUIView(_, context:)

└── class Coordinator: NSObject, PKCanvasViewDelegate
    ├── Binding: drawing
    ├── var isUpdatingFromSwiftUI: Bool
    │
    └── func canvasViewDrawingDidChange(_ canvasView:)
```

### Global Utilities (Referenced in multiple files)
```
// Defined in View extensions or globals (not shown in files)

var adaptiveCharacterFontSize: CGFloat
var adaptiveCanvasSize: CGFloat

// Data Models (referenced but not shown)
struct CharacterGlyph
├── script: Script
├── codepoint: UInt32
├── literal: String
├── readings: [String]
├── meaning: [String]
├── strokes: [StrokePath]
├── difficulty: Int
└── components: [String]

struct StrokePath
├── points: [StrokePoint]
└── metadata...

struct StrokePoint
├── x: Float
├── y: Float
└── timestamp...

struct PracticeScore
├── orderAccuracy: Double
├── shapeSimilarity: Double
└── total: Double (computed)

struct CharacterID
├── script: Script
└── codepoint: UInt32

enum Script
├── .hiragana
├── .katakana
└── .kanji
```

## File Organization Summary

### Core App (4 files)
- `KanjiKanaTrainerApp.swift` - App entry point
- `AppEnvironment.swift` - Dependency injection container
- `RootView.swift` - Main navigation hub
- `CanvasRepresentable.swift` - Shared drawing canvas

### License System (2 files)
- `LicenseGateView.swift` - License gate wrapper
- `LicenseAcceptanceView.swift` - License acceptance UI + ViewModel

### Data Layer (2 files)
- `GlyphRepository.swift` - Character data repository (3 scripts)
- `StrokeEvaluator.swift` - Drawing evaluation logic

### Practice Features (5 files)
- `PracticeView.swift` - Single character practice
- `SequentialPracticeView.swift` - Sequential practice UI
- `SequentialPracticeViewModel.swift` - Sequential practice logic
- `KanaSetSelector.swift` - Kana practice sets
- `ChineseNumberSetSelector.swift` - Chinese practice sets
- `SequentialPracticeHelp.swift` - Help system components

### Demo Features (3 files)
- `LessonView.swift` - Single character demo
- `SequentialDemoView.swift` - Sequential demo UI
- `DemoSetSelector.swift` - Demo set selection

### Documentation (5+ markdown files)
- `LICENSE_SYSTEM_IMPLEMENTATION.md`
- `SEQUENTIAL_PRACTICE_EXPANSION.md`
- `SEQUENTIAL_DEMO_IMPLEMENTATION.md`
- `LICENSE_SCROLL_FIX.md`
- `LICENSE_QUICK_REFERENCE.md`
- Plus others...

## Total Component Count

**Swift Files:** ~16 files
**Structs/Classes:** ~50+ types
**Protocols:** ~3 protocols
**Enums:** ~5+ enums
**View Extensions:** Multiple
**Supporting Types:** ~10+ data models

## Architecture Pattern

The app follows an **MVVM (Model-View-ViewModel)** pattern with:
- **Models**: CharacterGlyph, StrokePath, PracticeScore (data layer)
- **Views**: SwiftUI views (UI layer)
- **ViewModels**: Observable classes managing state and business logic
- **Repository Pattern**: For data access abstraction
- **Dependency Injection**: Via AppEnvironment

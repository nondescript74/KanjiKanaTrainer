# Sequential Practice Feature for Chinese Numbers 1-10

## Overview
Added a new sequential practice mode that allows users to practice Chinese numbers 1 through 10 in order, with navigation controls to move forward and backward through the sequence.

## New Files Created

### 1. SequentialPracticeViewModel.swift
A view model that manages the sequential practice flow:
- **Properties:**
  - `currentIndex`: Tracks the current position in the sequence
  - `currentGlyph`: The currently loaded character
  - `score`: Practice score for the current character
  - `isLoading`: Loading state indicator
  - `error`: Error handling

- **Key Methods:**
  - `loadCurrentGlyph()`: Loads the character at the current index
  - `nextGlyph()`: Advances to the next character
  - `previousGlyph()`: Goes back to the previous character
  - `evaluate(_:)`: Evaluates the user's drawing
  - `clearScore()`: Clears the current score

- **Factory Method:**
  - `chineseNumbers1to10(env:)`: Creates a view model preconfigured with Chinese numbers 1-10

### 2. SequentialPracticeView.swift
The SwiftUI view for sequential practice:
- Displays a progress indicator showing "X of Y" and a progress bar
- Shows the current character with its meaning
- Provides a drawing canvas for practice
- Includes "Clear" and "Evaluate" buttons
- Shows the score after evaluation
- Navigation buttons ("Previous" and "Next") to move through the sequence
- Properly disables navigation buttons at the start and end of the sequence

### 3. ViewHelpers.swift
Common view utilities used across practice views:
- `adaptiveCharacterFontSize`: Font size that adapts to device (iPad vs iPhone)
- `adaptiveCanvasSize`: Canvas size that adapts to device
- `CanvasRepresentable`: UIViewRepresentable wrapper for PKCanvasView

## Modified Files

### RootView.swift
Updated to show the sequential practice option when Chinese Numbers is selected:
- Added a new navigation link that appears only when "Chinese Numbers" is selected
- The link displays "Practice Numbers 1-10 Sequentially" with a list icon
- Uses distinctive styling (accent color background) to differentiate from other options

## How to Use

1. Launch the app
2. Select "Chinese Numbers" from the segmented control
3. You'll see three options:
   - **Demo**: View a demonstration of a random character
   - **Practice**: Practice a random Chinese number (existing feature)
   - **Practice Numbers 1-10 Sequentially**: NEW - Practice numbers in order

4. When in sequential practice mode:
   - Draw the displayed character on the canvas
   - Tap "Evaluate" to get your score
   - Tap "Clear" to clear the canvas and score
   - Use "Previous" and "Next" buttons to navigate through the sequence
   - Track your progress with the indicator at the top

## Technical Details

- The sequence uses the single-digit Chinese numbers (一, 二, 三, 四, 五, 六, 七, 八, 九, 十)
- Characters are loaded asynchronously from the GlyphBundleRepository
- Drawing evaluation uses the same AttemptEvaluator as the regular practice mode
- Navigation is handled via async/await for smooth transitions
- The drawing canvas is cleared automatically when navigating between characters

## Future Enhancements

Potential improvements for future versions:
- Add more number ranges (e.g., 1-20, 1-30)
- Save progress/scores for each number
- Add a "Review" mode to revisit numbers with low scores
- Add sound effects for correct answers
- Include readings (pinyin/Cantonese) practice
- Create custom sequences (user-selected numbers)

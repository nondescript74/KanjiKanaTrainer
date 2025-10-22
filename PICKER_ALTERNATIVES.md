# Alternative Picker Styles for RootView

If the segmented picker feels too crowded with three options, here are alternatives:

## Option 1: Menu Picker (Dropdown)

Replace the picker in `RootView.swift` with:

```swift
// Script selection - Menu style
Picker("Script", selection: $selectedScript) {
    ForEach(KanaScript.allCases, id: \.self) { script in
        Text(script.rawValue).tag(script)
    }
}
.pickerStyle(.menu)
.padding(.horizontal)
```

**Pros**: More compact, works on all devices
**Cons**: Requires extra tap to see options

## Option 2: Inline Picker (List)

```swift
// Script selection - Inline style
VStack(alignment: .leading) {
    Text("Select Script")
        .font(.headline)
    Picker("Script", selection: $selectedScript) {
        ForEach(KanaScript.allCases, id: \.self) { script in
            Text(script.rawValue).tag(script)
        }
    }
    .pickerStyle(.inline)
}
.padding(.horizontal)
```

**Pros**: All options visible, clear selection
**Cons**: Takes more vertical space

## Option 3: Wheel Picker

```swift
// Script selection - Wheel style
Picker("Script", selection: $selectedScript) {
    ForEach(KanaScript.allCases, id: \.self) { script in
        Text(script.rawValue).tag(script)
    }
}
.pickerStyle(.wheel)
.frame(height: 120)
.padding(.horizontal)
```

**Pros**: iOS-native feel, fun to use
**Cons**: Takes more vertical space

## Option 4: Custom Button Row

```swift
// Script selection - Custom buttons
VStack(alignment: .leading, spacing: 8) {
    Text("Select Script")
        .font(.headline)
    
    HStack(spacing: 12) {
        ForEach(KanaScript.allCases, id: \.self) { script in
            Button {
                selectedScript = script
            } label: {
                Text(script.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(selectedScript == script ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        selectedScript == script 
                            ? Color.accentColor 
                            : Color.secondary.opacity(0.2)
                    )
                    .cornerRadius(8)
            }
        }
    }
}
.padding(.horizontal)
```

**Pros**: Fully customizable, clear visual feedback
**Cons**: More code to maintain

## Option 5: Segmented with Short Labels

Keep segmented but use shorter labels:

```swift
enum KanaScript: String, CaseIterable {
    case hiragana = "Hiragana"
    case katakana = "Katakana"
    case chineseNumbers = "Chinese"  // ← Shorter!
    
    var fullName: String {
        switch self {
        case .hiragana: return "Hiragana"
        case .katakana: return "Katakana"
        case .chineseNumbers: return "Chinese Numbers"
        }
    }
}

// In the picker:
Picker("Script", selection: $selectedScript) {
    ForEach(KanaScript.allCases, id: \.self) { script in
        Text(script.rawValue).tag(script)
    }
}
.pickerStyle(.segmented)
.padding(.horizontal)
```

**Pros**: Keeps segmented style, more space
**Cons**: Less descriptive

## Option 6: Adaptive Picker (Best of Both Worlds)

Use segmented on larger screens, menu on smaller:

```swift
// Script selection - Adaptive
Picker("Script", selection: $selectedScript) {
    ForEach(KanaScript.allCases, id: \.self) { script in
        Text(script.rawValue).tag(script)
    }
}
.pickerStyle(.automatic)  // ← SwiftUI decides!
.padding(.horizontal)
```

**Pros**: Adapts to device/screen size
**Cons**: Less control over appearance

## Option 7: NavigationLink Style

Make it a separate selection screen:

```swift
NavigationLink {
    ScriptSelectionView(selectedScript: $selectedScript)
} label: {
    HStack {
        Text("Script")
            .foregroundStyle(.secondary)
        Spacer()
        Text(selectedScript.rawValue)
            .foregroundStyle(.primary)
        Image(systemName: "chevron.right")
            .foregroundStyle(.tertiary)
    }
    .padding()
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(10)
}
.padding(.horizontal)

// Separate view:
struct ScriptSelectionView: View {
    @Binding var selectedScript: RootView.KanaScript
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            ForEach(RootView.KanaScript.allCases, id: \.self) { script in
                Button {
                    selectedScript = script
                    dismiss()
                } label: {
                    HStack {
                        Text(script.rawValue)
                        Spacer()
                        if selectedScript == script {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Script")
    }
}
```

**Pros**: Plenty of space for descriptions
**Cons**: Extra navigation step

## Recommendation

For your current app, I recommend **Option 5** (shorter label) or **Option 1** (menu):

### Quick Fix - Shorter Label:
```swift
// Just change this line in RootView.swift:
case chineseNumbers = "Chinese"  // Instead of "Chinese Numbers"
```

### Or - Menu Picker:
```swift
// Just change this line in the picker:
.pickerStyle(.menu)  // Instead of .segmented
```

Both are one-line changes that solve the space issue!

## Testing on Different Devices

Test your choice on:
- iPhone SE (smallest screen)
- iPhone 13/14/15 (standard)
- iPhone 14/15 Pro Max (largest)
- iPad (much more space)

The segmented picker **should** work fine on most devices, but if you see truncation (three dots `...`), switch to a menu or shorter labels.

## Current Implementation

Your current implementation uses:
```swift
.pickerStyle(.segmented)
```

This works well for 2-3 options on most iPhone screens. With "Chinese Numbers" being longer, you might see:
- iPhone SE: Might truncate to "Chinese N..."
- iPhone 13+: Should display fine
- iPad: Plenty of space

## My Suggestion

Keep the segmented picker as-is for now, but if you notice issues on smaller devices, make this quick change:

```swift
case chineseNumbers = "中文"  // Chinese characters! Very short.
```

Or:
```swift
case chineseNumbers = "Chinese"  // Simple and clear
```

This maintains the nice segmented UI while ensuring it fits on all devices.

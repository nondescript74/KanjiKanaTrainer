# License System - Quick Reference

## For Users

### First Time Using the App
1. ✅ Read the entire license agreement (scroll to bottom)
2. ✅ Check the "I agree" box
3. ✅ Tap "Accept & Continue"
4. 🎉 Start using the app!

### Finding the License Later
1. Tap the **gear icon** (⚙️) in the top-right corner
2. Select **"View Full License"**
3. Read and tap "Done" when finished

### Your Privacy
- 🔒 **No data collection** — Your information stays private
- 💾 **Local storage only** — Everything stays on your device
- 🚫 **No tracking** — No analytics or monitoring
- 🎯 **Ad-free** — No advertisements ever

---

## For Developers

### How It Works
```swift
// App Launch Flow
LicenseGateView {
    RootView()  // Your main app
}

// Checks: Has user accepted current license version?
// NO  → Show LicenseAcceptanceView (must accept to continue)
// YES → Show RootView (main app)
```

### Key Files
| File | Purpose |
|------|---------|
| `license.md` | Full legal license text |
| `LicenseAcceptanceViewModel.swift` | Business logic & state |
| `LicenseAcceptanceView.swift` | Acceptance UI |
| `LicenseGateView.swift` | Conditional wrapper |
| `SettingsView.swift` | License review screen |

### Changing License Version
```swift
// In LicenseAcceptanceViewModel.swift
static let currentLicenseVersion = "2.0"  // Update this

// All users will need to re-accept
```

### Testing License Flow
```swift
// Reset acceptance (for development only)
let vm = LicenseAcceptanceViewModel()
vm.resetAcceptance()

// Next launch will show license again
```

### UserDefaults Keys
```swift
"acceptedLicenseVersion"    // String: "1.0"
"licenseAcceptanceDate"     // Date: timestamp of acceptance
```

### Requirements to Accept
1. **Scroll to bottom** → Progress must reach ≥95%
2. **Check the box** → User explicitly agrees
3. Both conditions must be met to enable "Accept" button

### Handling Decline
```swift
// User declines → App exits gracefully
UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    exit(0)
}
```

---

## Customization Guide

### Change Welcome Text
Edit in `LicenseAcceptanceView.swift`:
```swift
Text("Welcome to KanjiKana Trainer")  // Change this
Text("Please read and accept...")      // And this
```

### Change License Text
Edit in `LicenseAcceptanceViewModel.swift`:
```swift
let licenseText: String = """
    Your custom license text here
"""
```

### Change Scroll Threshold
Edit in `LicenseAcceptanceViewModel.swift`:
```swift
if progress >= 0.95  // Change 0.95 to your desired threshold (0.0-1.0)
```

### Change Button Colors
Edit in `LicenseAcceptanceView.swift`:
```swift
.background(Color.blue)      // Accept button (change .blue)
.background(Color.red)       // Decline button (change .red)
```

### Add Custom Actions on Accept
```swift
LicenseGateView {
    RootView()
}
.onAppear {
    // Your custom code after acceptance
}
```

---

## Troubleshooting

### License Keeps Showing
**Problem:** User accepted but license shows again every launch

**Solutions:**
- Check `currentLicenseVersion` hasn't changed
- Verify UserDefaults is persisting (not cleared)
- Check for multiple UserDefaults.standard.synchronize() calls

```swift
// Debug: Check what's stored
let stored = UserDefaults.standard.string(forKey: "acceptedLicenseVersion")
print("Stored version: \(stored ?? "none")")
print("Current version: \(LicenseAcceptanceViewModel.currentLicenseVersion)")
```

### Checkbox Won't Enable
**Problem:** User scrolled to bottom but checkbox disabled

**Solutions:**
- Verify scroll threshold logic (should be ≥0.95)
- Check GeometryReader is calculating correctly
- Test on different screen sizes

```swift
// Debug: Check scroll progress
print("Scroll progress: \(viewModel.scrollProgress)")
print("Has scrolled to bottom: \(viewModel.hasScrolledToBottom)")
```

### Accept Button Won't Enable
**Problem:** User scrolled and checked box but button stays disabled

**Solutions:**
- Verify `canAccept` computed property logic
- Check both conditions are true

```swift
// Debug: Check acceptance conditions
print("Scrolled: \(viewModel.hasScrolledToBottom)")
print("Agreed: \(viewModel.hasAgreed)")
print("Can accept: \(viewModel.canAccept)")
```

### App Doesn't Exit on Decline
**Problem:** Decline button doesn't close app

**Solutions:**
- Check alert action is connected
- Verify exit code executes
- May need to test on physical device (Simulator behaves differently)

### Text Too Small on Large Screens
**Problem:** License text is tiny on iPad

**Solutions:**
- Update font size based on device
```swift
.font(.system(viewModel.isIPad ? .body : .caption, design: .monospaced))
```

### Settings Icon Not Showing
**Problem:** Gear icon missing in navigation bar

**Solutions:**
- Verify RootView has `.toolbar` modifier
- Check NavigationStack (iOS 16+) or NavigationView (older)
- Ensure SettingsView file is in project

---

## Best Practices

### ✅ DO
- Keep license text clear and readable
- Test on multiple device sizes
- Support Dynamic Type (accessibility)
- Provide easy access to review license later
- Use semantic colors (works in light/dark mode)
- Show acceptance date in Settings
- Version your license changes

### ❌ DON'T
- Allow bypassing the license requirement
- Make text too small or hard to read
- Auto-accept without user interaction
- Hide the decline option
- Remove the scroll requirement
- Forget to update version when license changes
- Collect data without updating license

---

## License Types Used

### Main Software: CC BY 4.0
- ✅ Commercial use allowed
- ✅ Modification allowed
- ✅ Distribution allowed
- ✅ Private use allowed
- ⚠️ Attribution required
- ⚠️ Changes must be stated

### Stroke Data: CC BY 2.0
- ✅ Sharing allowed
- ✅ Adaptation allowed
- ⚠️ Attribution required
- ⚠️ Link to license required

---

## API Reference

### LicenseAcceptanceViewModel

```swift
class LicenseAcceptanceViewModel: ObservableObject {
    // Properties
    @Published var hasScrolledToBottom: Bool
    @Published var hasAgreed: Bool
    @Published var scrollProgress: CGFloat
    var canAccept: Bool { get }
    var needsLicenseAcceptance: Bool { get }
    var licenseAcceptanceDate: Date? { get }
    let licenseText: String
    
    // Methods
    func acceptLicense()
    func updateScrollProgress(_ progress: CGFloat)
    func resetAcceptance()
    
    // Static
    static let currentLicenseVersion: String
}
```

### LicenseAcceptanceView

```swift
struct LicenseAcceptanceView: View {
    init(
        onAccept: @escaping () -> Void,
        onDecline: (() -> Void)? = nil
    )
}
```

### LicenseGateView

```swift
struct LicenseGateView<Content: View>: View {
    init(@ViewBuilder content: () -> Content)
}
```

---

## FAQ

**Q: Can users skip the license?**  
A: No, the license is required. Users must accept or exit the app.

**Q: What happens if license version changes?**  
A: Users must re-accept the new version.

**Q: Is the acceptance stored locally or in cloud?**  
A: Locally in UserDefaults on the device.

**Q: Can I see when user accepted license?**  
A: Yes, shown in Settings view with timestamp.

**Q: Does this work offline?**  
A: Yes, completely offline. No network required.

**Q: Is this GDPR compliant?**  
A: The implementation supports compliance (explicit consent, clear terms), but legal review recommended for production.

**Q: Can I export/print the license?**  
A: Not currently implemented, but can be added.

**Q: What if user updates iOS?**  
A: Acceptance persists across iOS updates.

**Q: What if user deletes and reinstalls?**  
A: Must accept again (UserDefaults cleared on uninstall).

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 3, 2025 | Initial implementation |

---

## Support

For implementation questions or issues:
1. Check this Quick Reference
2. Review `LICENSE_SYSTEM_IMPLEMENTATION.md` for details
3. Examine `license.md` for legal text
4. Test with `resetAcceptance()` for debugging

---

*Last Updated: November 3, 2025*

# License System - Flow Diagrams

## App Launch Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        App Launches                              │
│                  (KanjiKanaTrainerApp.swift)                     │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                     LicenseGateView                              │
│                                                                   │
│   Check: needsLicenseAcceptance?                                │
│   (Compare stored version with currentLicenseVersion)            │
└───────┬───────────────────────────────────────────┬─────────────┘
        │                                           │
        │ NO (already accepted)                     │ YES (needs acceptance)
        │                                           │
        ▼                                           ▼
┌──────────────────────┐              ┌────────────────────────────┐
│     RootView         │              │  LicenseAcceptanceView     │
│   (Main App)         │              │   (Must Accept)            │
│                      │              │                            │
│  • Demo              │              │  • Show license text       │
│  • Practice          │              │  • Track scroll            │
│  • Sequential Sets   │              │  • Require checkbox        │
│  • Settings          │              │  • Enable accept button    │
└──────────────────────┘              └────────────┬───────────────┘
                                                   │
                                      ┌────────────┴───────────┐
                                      │                        │
                                ACCEPT                     DECLINE
                                      │                        │
                                      ▼                        ▼
                        ┌─────────────────────┐    ┌─────────────────┐
                        │  acceptLicense()    │    │  Show Alert     │
                        │  • Store version    │    │  "Exit App?"    │
                        │  • Store date       │    └────┬────────────┘
                        │  • Transition to    │         │
                        │    RootView         │    ┌────┴─────────┐
                        └─────────────────────┘    │              │
                                                REVIEW        EXIT APP
                                                   │              │
                                                   ▼              ▼
                                            ┌─────────┐    ┌──────────┐
                                            │  Stay   │    │ exit(0)  │
                                            │  on     │    │          │
                                            │ License │    └──────────┘
                                            │  View   │
                                            └─────────┘
```

---

## User Interaction Flow

```
                    ┌──────────────────────┐
                    │   User Opens App     │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  License Appears     │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ Header         │  │
                    │  │ • Icon         │  │
                    │  │ • Welcome text │  │
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ Scrollable     │  │
                    │  │ License Text   │  │◄─── User scrolls
                    │  │                │  │     Progress: 0% → 95%
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ ↓ Scroll to    │  │◄─── Shows until 95%
                    │  │   bottom       │  │
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ Progress Bar   │  │◄─── Updates real-time
                    │  │ ▓▓▓▓▓▓▓░░░ 60% │  │
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ ☐ I agree      │  │◄─── Disabled until 95%
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ [Decline]      │  │◄─── Always enabled
                    │  │ [Accept] (OFF) │  │◄─── Disabled
                    │  └────────────────┘  │
                    └──────────────────────┘
                               │
                               │ User scrolls to 95%
                               ▼
                    ┌──────────────────────┐
                    │  Checkbox Enables    │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ ☐ I agree      │  │◄─── NOW enabled
                    │  │ (tap to check) │  │
                    │  └────────────────┘  │
                    └──────────┬───────────┘
                               │
                               │ User checks box
                               ▼
                    ┌──────────────────────┐
                    │  Accept Button       │
                    │  Enables             │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ ☑ I agree      │  │◄─── Checked
                    │  └────────────────┘  │
                    │                      │
                    │  ┌────────────────┐  │
                    │  │ [Decline]      │  │
                    │  │ [Accept] (ON)  │  │◄─── NOW enabled
                    │  └────────────────┘  │
                    └──────────┬───────────┘
                               │
                               │ User taps Accept
                               ▼
                    ┌──────────────────────┐
                    │  Save Acceptance     │
                    │  • Version: "1.0"    │
                    │  • Date: 11/3/2025   │
                    │  • UserDefaults      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │  Transition to       │
                    │  Main App            │
                    │  (RootView)          │
                    └──────────────────────┘
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────────────────────┐
│           LicenseAcceptanceViewModel State Machine              │
└─────────────────────────────────────────────────────────────────┘

Initial State:
┌──────────────────────────────────┐
│ hasScrolledToBottom = false      │
│ hasAgreed = false                │
│ scrollProgress = 0.0             │
│ canAccept = false                │
└──────────────┬───────────────────┘
               │
               │ User scrolls...
               ▼
┌──────────────────────────────────┐
│ updateScrollProgress(0.5)        │
│ → scrollProgress = 0.5           │
│ → hasScrolledToBottom = false    │◄─── Still false (need 95%)
│ → canAccept = false              │
└──────────────┬───────────────────┘
               │
               │ User continues scrolling...
               ▼
┌──────────────────────────────────┐
│ updateScrollProgress(0.96)       │
│ → scrollProgress = 0.96          │
│ → hasScrolledToBottom = TRUE ✓   │◄─── NOW true (≥95%)
│ → canAccept = false              │◄─── Still false (needs checkbox)
└──────────────┬───────────────────┘
               │
               │ User checks box...
               ▼
┌──────────────────────────────────┐
│ hasAgreed = TRUE ✓               │
│ → canAccept = TRUE ✓             │◄─── Both conditions met!
└──────────────┬───────────────────┘
               │
               │ User taps Accept...
               ▼
┌──────────────────────────────────┐
│ acceptLicense()                  │
│ → UserDefaults.set(version)      │
│ → UserDefaults.set(date)         │
│ → needsLicenseAcceptance = false │
└──────────────────────────────────┘

Computed Property Logic:
┌──────────────────────────────────────────────────────────┐
│ canAccept:                                               │
│   return hasScrolledToBottom && hasAgreed                │
│                                                          │
│   Truth Table:                                           │
│   ┌──────────┬──────────┬──────────┐                   │
│   │ Scrolled │  Agreed  │ canAccept│                   │
│   ├──────────┼──────────┼──────────┤                   │
│   │  false   │  false   │  FALSE   │                   │
│   │  false   │  true    │  FALSE   │                   │
│   │  true    │  false   │  FALSE   │                   │
│   │  true    │  true    │  TRUE ✓  │                   │
│   └──────────┴──────────┴──────────┘                   │
└──────────────────────────────────────────────────────────┘
```

---

## Data Persistence Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    UserDefaults Storage                          │
└─────────────────────────────────────────────────────────────────┘

WRITE (on acceptance):
┌────────────────────┐
│ acceptLicense()    │
└────────┬───────────┘
         │
         ├─────────────────────────────────────────┐
         │                                         │
         ▼                                         ▼
┌────────────────────────┐              ┌──────────────────────┐
│ UserDefaults.standard  │              │ UserDefaults.standard│
│ .set(                  │              │ .set(                │
│   "1.0",               │              │   Date(),            │
│   forKey:              │              │   forKey:            │
│   "acceptedLicense     │              │   "licenseAcceptance │
│    Version"            │              │    Date"             │
│ )                      │              │ )                    │
└────────────────────────┘              └──────────────────────┘
         │                                         │
         └─────────────────┬───────────────────────┘
                           │
                           ▼
                  ┌────────────────┐
                  │ .synchronize() │
                  └────────────────┘
                           │
                           ▼
              ┌─────────────────────────┐
              │ Persisted to disk       │
              │ Survives app restarts   │
              └─────────────────────────┘

READ (on app launch):
┌─────────────────────────┐
│ needsLicenseAcceptance  │
└────────┬────────────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│ UserDefaults.standard                        │
│ .string(forKey: "acceptedLicenseVersion")    │
└────────┬─────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│ Compare with currentLicenseVersion           │
│                                              │
│ Stored: "1.0" == Current: "1.0"?            │
└────────┬─────────────────────────────────────┘
         │
    ┌────┴─────┐
    │          │
  YES         NO
    │          │
    ▼          ▼
┌───────┐  ┌──────────────┐
│ Skip  │  │ Show License │
│License│  │ Again        │
└───────┘  └──────────────┘
```

---

## Settings Integration Flow

```
┌──────────────────────────────────────────────────────────────┐
│                        RootView                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Navigation Bar                          [⚙ Settings] │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────┬───────────────────────┘
                                       │ User taps gear icon
                                       ▼
┌──────────────────────────────────────────────────────────────┐
│                     SettingsView                             │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  About                                                 │  │
│  │  • App name & version                                  │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  Copyright                                             │  │
│  │  • © 2025 Zahirudeen Premji                           │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  License                                               │  │
│  │  • [View Full License] ──────────┐                    │  │
│  │  • Accepted: Nov 3, 2025         │                    │  │
│  ├────────────────────────────────┐ │                    │  │
│  │  Privacy                       │ │                    │  │
│  │  • No data collection          │ │                    │  │
│  │  • Local storage only          │ │                    │  │
│  ├────────────────────────────────┤ │                    │  │
│  │  Credits                       │ │                    │  │
│  │  • Open source contributors    │ │                    │  │
│  └────────────────────────────────┘ │                    │  │
└─────────────────────────────────────┼────────────────────┘  │
                                      │                        │
                                      │ User taps button       │
                                      ▼                        │
                           ┌──────────────────────┐            │
                           │  Sheet Presents      │            │
                           │  Full License Text   │            │
                           │                      │            │
                           │  ┌────────────────┐  │            │
                           │  │ Full License   │  │            │
                           │  │                │  │            │
                           │  │ (scrollable    │  │            │
                           │  │  monospaced    │  │            │
                           │  │  text)         │  │            │
                           │  │                │  │            │
                           │  │                │  │            │
                           │  └────────────────┘  │            │
                           │                      │            │
                           │  [Done]              │            │
                           └──────────┬───────────┘            │
                                      │ Dismisses              │
                                      ▼                        │
                           ┌──────────────────────┐            │
                           │  Back to Settings    │            │
                           └──────────────────────┘            │
```

---

## Version Update Flow

```
Developer Updates License Version:
┌────────────────────────────────────────┐
│ LicenseAcceptanceViewModel.swift       │
│                                        │
│ - static let currentLicenseVersion     │
│   = "1.0"  // OLD                      │
│                                        │
│ + static let currentLicenseVersion     │
│   = "2.0"  // NEW                      │
└────────────┬───────────────────────────┘
             │
             │ User with v1.0 acceptance launches app
             ▼
┌────────────────────────────────────────┐
│ LicenseGateView checks:                │
│                                        │
│ Stored: "1.0"                          │
│ Current: "2.0"                         │
│                                        │
│ "1.0" == "2.0"? NO                     │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│ needsLicenseAcceptance = TRUE          │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│ Show LicenseAcceptanceView again       │
│ (even though user accepted v1.0)       │
└────────────┬───────────────────────────┘
             │
             │ User accepts v2.0
             ▼
┌────────────────────────────────────────┐
│ acceptLicense()                        │
│ → Store "2.0"                          │
│ → Store new date                       │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│ UserDefaults now has:                  │
│ "acceptedLicenseVersion" = "2.0"       │
│ "licenseAcceptanceDate" = new date     │
└────────────────────────────────────────┘
```

---

## Component Dependency Graph

```
                    KanjiKanaTrainerApp
                            │
                            │ wraps with
                            ▼
                    LicenseGateView
                     │            │
         needs       │            │ shows when
       acceptance?   │            │ accepted
                     ▼            ▼
          License          RootView ─────┐
          Acceptance           │         │
          View                 │         │ navigates to
             │                 │         ▼
             │                 │    SettingsView
             │                 │         │
             │                 │         │ can show
             │                 │         ▼
             │                 │    License text
             ├─────────────────┴──────in sheet
             │
             │ uses
             ▼
        LicenseAcceptanceViewModel
             │
             │ stores/reads
             ▼
        UserDefaults
             │
             ├── "acceptedLicenseVersion"
             └── "licenseAcceptanceDate"

Key:
────  Flow/Navigation
│     Dependency
▼     Direction
```

---

## Error Handling Flow

```
Edge Cases & Error Handling:

1. UserDefaults Write Fails
   ┌──────────────────────┐
   │ acceptLicense()      │
   │ → .set() fails       │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Next launch checks:      │
   │ acceptedVersion = nil    │
   │ → Shows license again    │
   └──────────────────────────┘

2. App Killed During Acceptance
   ┌──────────────────────┐
   │ User scrolling...    │
   │ → App killed         │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Next launch:             │
   │ No acceptance stored     │
   │ → Shows license again    │
   └──────────────────────────┘

3. Very Small Screen (Scroll Issues)
   ┌──────────────────────┐
   │ iPhone SE            │
   │ Small viewport       │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ GeometryReader adjusts   │
   │ Scroll still works       │
   │ Progress still tracks    │
   └──────────────────────────┘

4. User Backgrounding During Accept
   ┌──────────────────────┐
   │ User taps Accept     │
   │ → App backgrounded   │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ .synchronize() ensures   │
   │ data written to disk     │
   │ Safe even if interrupted │
   └──────────────────────────┘
```

---

## Summary Decision Tree

```
                    ┌─────────────────┐
                    │  App Launches   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌────────────────────┐
                    │ Check UserDefaults │
                    │ for version        │
                    └────────┬───────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
         ┌──────▼─────┐           ┌──────▼──────┐
         │  Stored    │           │  No stored  │
         │  version   │           │  version    │
         │  found     │           │  found      │
         └──────┬─────┘           └──────┬──────┘
                │                        │
                │                        │
         ┌──────▼────────────────────────▼─────┐
         │ Compare with currentLicenseVersion  │
         └──────┬─────────────────────────┬────┘
                │                         │
         ┌──────▼──────┐          ┌──────▼──────┐
         │ Versions    │          │ Versions    │
         │ MATCH       │          │ DON'T MATCH │
         │ (1.0 == 1.0)│          │ (nil != 1.0)│
         └──────┬──────┘          └──────┬──────┘
                │                        │
                ▼                        ▼
         ┌──────────────┐        ┌────────────────┐
         │ Show RootView│        │ Show License   │
         │ (Main App)   │        │ Acceptance View│
         └──────────────┘        └───────┬────────┘
                                         │
                                         │
                        ┌────────────────┴─────────────┐
                        │                              │
                 ┌──────▼──────┐              ┌────────▼────────┐
                 │ User Accepts│              │ User Declines   │
                 └──────┬──────┘              └────────┬────────┘
                        │                              │
                        ▼                              ▼
                 ┌──────────────┐              ┌────────────────┐
                 │ Store version│              │ Show alert     │
                 │ Store date   │              └────────┬───────┘
                 └──────┬───────┘                       │
                        │                    ┌──────────┴──────┐
                        ▼                    │                 │
                 ┌──────────────┐      ┌────▼─────┐   ┌───────▼───┐
                 │ Show RootView│      │ Review   │   │ Exit App  │
                 │ (Main App)   │      │ Again    │   │  exit(0)  │
                 └──────────────┘      └──────────┘   └───────────┘
```

---

*Diagrams created: November 3, 2025*

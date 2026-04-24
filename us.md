# SafeCycle: Private Period Tracker - iOS App Development Guide

## Executive Summary

SafeCycle is a privacy-first menstrual cycle tracking app designed for the US market in the Post-Roe era. It addresses the critical trust gap in period tracking apps by offering 100% local data storage with AES-256-GCM encryption, zero network permissions, a stealth mode with calculator disguise, and a one-time purchase model at $7.99.

**Core Differentiators:**
- **Military-grade privacy**: AES-256-GCM encryption + Face ID/Touch ID + Stealth PIN + zero network access
- **Stealth Mode**: Duress PIN triggers a fully functional calculator interface — no other period app offers this
- **One-time purchase**: $7.99 forever vs. Flo's $9.99/year subscription (saves $91.91 over 10 years)
- **Zero data collection**: No accounts, no cloud, no third-party SDKs, no analytics — Info.plist declares no network usage
- **Native SwiftUI**: Smooth 60fps animations and iOS-native experience vs. React Native competitors (Ephira)
- **Comprehensive symptom tracking**: 30+ symptom categories (mood, pain, digestion, sleep, skin, energy) — more than Euki or Drip

**Target Market**: US women aged 18-45, particularly the 22M living in abortion-restricted states who are most concerned about period data privacy.

---

## Competitive Analysis

| Dimension | Flo ($9.99/yr) | Clue ($9.99/yr) | Euki (Free) | Monthly (Free+) | **SafeCycle ($7.99)** |
|-----------|---------|----------|--------|---------|---------------------|
| Data Storage | Cloud (GDPR) | Cloud (GDPR) | Local | Local | **Local + AES-256 encrypted** |
| Data Sharing | Shares to 3rd party | Does not share | No data to share | Does not share | **Zero data to share** |
| Subpoena Risk | High (12 cases) | Medium (EU but possible) | None (local) | None (local) | **None (local + stealth)** |
| Stealth/Disguise | No | No | Duress PIN (basic) | No | **Full calculator disguise** |
| Face ID Lock | No | Paid only | No | No | **Free included** |
| Symptom Tracking | 66 types | Detailed | Basic | Basic | **30+ categories** |
| Period Prediction | AI-driven | Science-driven | Simple date calc | Simple | **Weighted avg + confidence** |
| UI Quality | 5/5 | 4/5 | 2/5 | 3/5 | **5/5 (SwiftUI native)** |
| Pricing | $9.99/yr sub | $9.99/yr sub | Free | Free + IAP | **$7.99 one-time** |
| Open Source | No | No | Yes | No | No (auditable privacy policy) |
| Privacy Rating | Poor (FTC fine) | Medium (cloud+GDPR) | Good | Good | **Best** |

**Key Insight**: No existing app combines military-grade encryption, stealth mode, comprehensive tracking, AND beautiful native UI. SafeCycle fills this exact gap.

---

## Technical Architecture

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| UI Layer | SwiftUI | Declarative UI, native performance, fluid animations |
| Data Layer | SwiftData (iOS 17+) | Local persistence, automatic CRUD, no manual SQLite |
| Encryption | CryptoKit (AES-256-GCM) | Database encryption, key derivation |
| Authentication | LocalAuthentication | Face ID / Touch ID |
| Charts | Swift Charts | Cycle analysis visualization |
| Notifications | UserNotifications | Period/symptom reminders (stealth disguised) |
| Keychain | Security framework | Store encryption keys, PIN codes |

### Module Structure & File Organization

```
SafeCycle/
├── SafeCycleApp.swift              # App entry point
├── Models/
│   ├── PeriodRecord.swift          # SwiftData period record model
│   ├── DailyLog.swift              # SwiftData daily symptom log model
│   ├── CycleStats.swift            # SwiftData cycle statistics model
│   └── CyclePhase.swift            # Cycle phase enum
├── Services/
│   ├── EncryptionService.swift     # AES-256-GCM encryption/decryption
│   ├── KeychainHelper.swift        # Keychain read/write helper
│   ├── CyclePredictor.swift        # Period prediction algorithm
│   ├── StealthNotificationService.swift  # Disguised notification scheduling
│   └── DataExportService.swift     # Encrypted JSON backup + PDF report
├── ViewModels/
│   ├── DashboardViewModel.swift    # Main dashboard logic
│   ├── CalendarViewModel.swift     # Calendar view logic
│   ├── LogViewModel.swift          # Symptom logging logic
│   ├── SettingsViewModel.swift     # Settings management
│   ├── PinViewModel.swift          # PIN verification + stealth mode
│   └── ChartsViewModel.swift       # Charts data aggregation
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift       # 3-page onboarding carousel
│   │   ├── PinSetupView.swift      # Real PIN setup
│   │   ├── StealthPinSetupView.swift  # Stealth PIN setup
│   │   └── FirstPeriodView.swift   # First period date entry
│   ├── Lock/
│   │   ├── LockScreenView.swift    # PIN/Face ID entry screen
│   │   └── CalculatorStealthView.swift  # Full calculator disguise
│   ├── Main/
│   │   ├── DashboardView.swift     # Cycle countdown + phase + predictions
│   │   ├── CalendarView.swift      # Monthly calendar with period markers
│   │   ├── DailyLogView.swift      # 30+ symptom category selector
│   │   ├── ChartsView.swift        # Cycle trends + symptom frequency
│   │   └── SettingsView.swift      # PIN mgmt + stealth + export + policies
│   └── Components/
│       ├── PhaseCard.swift         # Cycle phase display card
│       ├── StatCard.swift          # Statistics mini card
│       ├── SymptomPicker.swift     # Multi-category symptom selector
│       └── FlowLevelPicker.swift   # Period flow level selector
└── Utilities/
    ├── Constants.swift             # App-wide constants
    └── DateExtensions.swift        # Date helper extensions
```

---

## Implementation Flow

### Step 1: Data Layer (SwiftData Models + Encryption)
- Create PeriodRecord, DailyLog, CycleStats SwiftData models
- Implement EncryptionService with AES-256-GCM
- Implement KeychainHelper for secure key/PIN storage
- All sensitive fields (symptoms, moods, notes) encrypted before storage

### Step 2: Security Layer (PIN + Face ID + Stealth)
- Implement PinViewModel with real PIN + stealth PIN verification
- Implement LockScreenView with PIN entry + Face ID
- Implement CalculatorStealthView (fully functional calculator)
- Integrate LocalAuthentication for biometric unlock

### Step 3: Core Algorithm (Cycle Prediction)
- Implement CyclePredictor with weighted average algorithm
- Calculate confidence based on standard deviation
- Determine current cycle phase (menstrual/follicular/ovulation/luteal)

### Step 4: Onboarding Flow
- Welcome carousel (3 pages)
- Real PIN setup
- Stealth PIN setup (optional but recommended)
- Face ID enable prompt
- First period date entry

### Step 5: Main UI - Dashboard
- Cycle countdown (days until next period)
- Current phase display with emoji + color
- 4 stat cards (predicted date, avg cycle, period length, confidence)
- Two CTA buttons (Mark Period Start, Today's Log)

### Step 6: Main UI - Calendar
- Monthly calendar grid
- Period days highlighted in phase color
- Symptom color blocks on calendar dates
- Tap date to view/add daily log

### Step 7: Main UI - Daily Log
- 30+ symptom categories: Mood, Pain, Digestion, Sleep, Skin, Energy
- Flow level picker (1-4 scale)
- Free-text notes (encrypted)
- Date navigation

### Step 8: Main UI - Charts
- Cycle length trend line chart
- Symptom frequency bar chart
- Phase distribution pie chart
- Filter by time range (3/6/12 months)

### Step 9: Main UI - Settings
- PIN management (change real/stealth PIN)
- Face ID toggle
- Notification preferences (time, stealth mode)
- Data export (encrypted JSON + PDF)
- Privacy policy + support links
- App version display

### Step 10: Notifications
- Stealth notification service
- "Daily Reminder" title (never mentions period)
- "Weekly Update" for upcoming period alerts
- User-configurable reminder time

### Step 11: Theme & Polish
- Dark mode as default (privacy = dark = security)
- Light mode as option
- Phase-based color theming
- Smooth SwiftUI animations

---

## UI/UX Design Specifications

### Design Principles (Following Apple HIG 2025)
1. **Clarity**: Large countdown numbers, clear phase indicators, minimal cognitive load
2. **Deference**: Content-first design, no decorative elements, focus on user data
3. **Depth**: Subtle layering with cards, shadows for hierarchy, blur for lock screen

### Color System

| Element | Dark Mode | Light Mode | Purpose |
|---------|-----------|------------|---------|
| Background | #1A1A3E (deep indigo) | #F5F5F7 | Security feeling / Clean |
| Primary Text | #FFFFFF | #1A1A3E | High contrast |
| Menstrual Phase | #E85D75 (soft red) | #E85D75 | Period indicator |
| Follicular Phase | #7EC8A0 (fresh green) | #7EC8A0 | Growth indicator |
| Ovulation Phase | #F4A261 (warm orange) | #F4A261 | Fertility indicator |
| Luteal Phase | #8B7EB8 (calm purple) | #8B7EB8 | Rest indicator |
| Accent | #F2E4BF (light gold) | #4A6FA5 | Actions/highlights |
| Card Background | #252550 | #FFFFFF | Content containers |

### Typography
- Countdown number: SF Pro Display, 72pt, weight .bold
- Phase label: SF Pro Text, 20pt, weight .semibold
- Card values: SF Pro Text, 16pt, weight .medium
- Body text: SF Pro Text, 15pt, weight .regular

### Animations

| Interaction | Animation | Duration | Detail |
|-------------|-----------|----------|--------|
| Page transition | SwiftUI .slide | 0.35s | iOS standard slide in/out |
| Phase change | Color gradient transition | 0.5s | Smooth phase color shift |
| Period mark | Circular ripple | 0.3s | Soft red ripple from touch point |
| Encryption save | Lock icon micro-bounce | 0.2s | Security confirmation |
| Stealth switch | Black screen → Calculator | 0.15s | Instant, no trace |
| Unlock success | Blur → Clear | 0.3s | Face ID verified content reveal |

### App Icon Design
- **Style**: Minimalist, flat, no period-identifying symbols
- **Elements**: Lock icon (safety) + Crescent moon (cycle) — simple line art
- **Background**: Deep indigo (#1A1A3E)
- **Icon color**: Light gold (#F2E4BF)
- **No blood drops, flowers, or uterus symbols** — icon must not reveal app category

### Notification Design
- **Title**: "Daily Reminder" (never mentions period)
- **Body**: "Time for your daily check-in" (generic)
- **Upcoming period**: "Weekly Update" / "Your weekly summary is ready"
- **Sound**: Default system sound

---

## Code Generation Rules

1. **Zero network permissions**: Info.plist must NOT declare any network usage. No third-party SDKs.
2. **Full encryption**: All sensitive fields (symptoms, moods, notes) encrypted with AES-256-GCM before writing to SwiftData, decrypted on read.
3. **Keychain for keys**: Encryption keys and PIN codes stored ONLY in iOS Keychain, never in SwiftData.
4. **Minimal data principle**: Only collect necessary data (period dates + symptoms). No age, weight, or height.
5. **Clean deletion**: Deleting the app deletes all data (standard iOS behavior). No account deletion flow needed.
6. **Swift Concurrency**: All database operations use async/await. UI thread must never block.
7. **Accessibility**: VoiceOver support, Dynamic Type support, high contrast support.
8. **Dark mode first**: Dark mode is the default design. Light mode is optional.
9. **No comments in code** unless explicitly requested.
10. **iPad layout**: Main content in ScrollView must use `.frame(maxWidth: 720).frame(maxWidth: .infinity)`.
11. **Never use `.tabViewStyle(.sidebarAdaptable)`** or similar restrictive styles.
12. **Use `Color.accentColor`** instead of `ShapeStyle.accent`.
13. **Never hardcode version numbers** — always read from Bundle.main.infoDictionary.
14. **All SwiftData attributes must be optional or have default values**.
15. **Use `@Observable` macro** (iOS 17+) — do NOT add `ObservableObject` conformance to views already marked `@Observable`.

---

## Testing & Validation Standards

### Build Validation
- Must compile with zero errors on iPhone (iPhone XS Max simulator)
- Must compile with zero errors on iPad (iPad Pro 13-inch M4 simulator)
- No warnings related to deprecated APIs

### Functional Testing
- PIN entry: Real PIN shows dashboard, Stealth PIN shows calculator
- Face ID: Biometric unlock works on supported devices
- Period tracking: Can log period start/end dates
- Symptom logging: Can select symptoms from all 30+ categories
- Cycle prediction: Algorithm produces reasonable predictions after 2+ cycles
- Data encryption: Verify sensitive fields are encrypted in SwiftData
- Stealth notifications: Verify notifications never mention "period" or "menstrual"
- Data export: Encrypted JSON backup generates correctly
- Dark/Light mode: Both themes render correctly

### Privacy Validation
- Info.plist contains NO network usage descriptions
- No Firebase, Analytics, Crashlytics, or third-party SDKs
- All sensitive data encrypted at rest
- Keychain items not accessible to other apps

---

## Build & Deployment Checklist

1. [ ] Verify Bundle ID: `com.zzoutuo.SafeCycle`
2. [ ] Verify iOS Deployment Target: 17.0
3. [ ] Verify no network permissions in Info.plist
4. [ ] Verify App Icon configured in Assets.xcassets
5. [ ] Build succeeds on iPhone simulator
6. [ ] Build succeeds on iPad simulator
7. [ ] All onboarding flows work correctly
8. [ ] Stealth mode (calculator) works correctly
9. [ ] Notifications are properly disguised
10. [ ] Data export generates valid encrypted JSON
11. [ ] Privacy policy page deployed and accessible
12. [ ] Support page deployed and accessible
13. [ ] App Store metadata prepared (keytext.md)
14. [ ] Screenshots captured for iPhone and iPad

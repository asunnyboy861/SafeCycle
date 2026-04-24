# Capabilities Configuration Guide

## Configuration Summary

| Capability | Status | Notes |
|------------|--------|-------|
| **Face ID (LocalAuthentication)** | ✅ Auto-configured | INFOPLIST_KEY_NSFaceIDUsageDescription set |
| **Notifications (UserNotifications)** | ✅ Auto-configured | Code-level request, no capability needed |
| **Keychain (Security)** | ✅ Auto-configured | Code-level access, no capability needed |
| **CryptoKit** | ✅ Auto-configured | Framework available on iOS 17+, no capability needed |
| **SwiftData** | ✅ Auto-configured | Framework available on iOS 17+, no capability needed |
| **iCloud / CloudKit** | ⏭️ Skipped | App is 100% local storage, zero cloud by design |
| **HealthKit** | ⏭️ Skipped | Phase 2 feature, not in initial release |
| **Camera** | ⏭️ Skipped | Not needed for this app |
| **Location** | ⏭️ Skipped | Not needed for this app |

**Why no iCloud/CloudKit**: SafeCycle's core value proposition is 100% local data storage. Adding cloud sync would contradict the privacy-first positioning. Data export is provided via encrypted JSON backup for device migration.

**Why no HealthKit**: HealthKit integration is planned for Phase 2 (post-launch). Not included in v1.0 to keep the privacy story simple and avoid additional permission prompts.

**Verification**: Build succeeded without any capabilities enabled ✅

---

## Auto-Configured Capabilities (✅ Success - No Action Needed)

### 1. Face ID (LocalAuthentication)
**Status**: ✅ Successfully configured automatically
**Configuration Details**:
- **Info.plist**: `NSFaceIDUsageDescription` = "SafeCycle uses Face ID to securely unlock your private health data."
- **Framework**: LocalAuthentication (built-in, no import needed beyond code)
- **Verification**: Build succeeded

### 2. Notifications (UserNotifications)
**Status**: ✅ No capability configuration needed
**Configuration Details**:
- UserNotifications framework is code-level only
- Permission requested at runtime via `UNUserNotificationCenter.requestAuthorization()`
- No Info.plist key required for local notifications
- **Stealth design**: Notifications titled "Daily Reminder" — never mention period

### 3. Keychain (Security)
**Status**: ✅ No capability configuration needed
**Configuration Details**:
- Keychain access via Security framework (code-level)
- Used to store: encryption keys, real PIN, stealth PIN, device salt
- No Keychain Sharing capability needed (single-app access only)

### 4. CryptoKit
**Status**: ✅ No capability configuration needed
**Configuration Details**:
- CryptoKit is a system framework available on iOS 17+
- Used for: AES-256-GCM encryption, HKDF key derivation, SHA256 hashing
- No entitlements or Info.plist keys required

---

## Summary Checklist

### Auto-Configured (Verified)
- [x] Face ID usage description configured
- [x] Notifications code-level ready
- [x] Keychain code-level ready
- [x] CryptoKit code-level ready
- [x] SwiftData code-level ready
- [x] All capabilities build test passed

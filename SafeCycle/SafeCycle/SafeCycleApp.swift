import SwiftUI
import SwiftData

@main
struct SafeCycleApp: App {
    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding = false
    @AppStorage("has_set_pin") private var hasSetPin = false
    @AppStorage("is_stealth_mode") private var isStealthMode = false
    @State private var isUnlocked = false

    private var isDebugMode: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    WelcomeView(hasCompletedOnboarding: $hasCompletedOnboarding)
                } else if !hasSetPin {
                    PinSetupView(onComplete: {
                        hasSetPin = true
                        isUnlocked = true
                    })
                } else if !isUnlocked && !isDebugMode {
                    LockScreenView(onUnlock: { stealth in
                        isStealthMode = stealth
                        isUnlocked = true
                    })
                } else if isStealthMode && !isDebugMode {
                    CalculatorStealthView()
                } else {
                    MainTabView()
                }
            }
            .modelContainer(for: [PeriodRecord.self, DailyLog.self, CycleStats.self])
            .tint(Color(hex: "F2E4BF"))
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            ChartsView()
                .tabItem {
                    Label("Charts", systemImage: "chart.bar.fill")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color(hex: "F2E4BF"))
    }
}

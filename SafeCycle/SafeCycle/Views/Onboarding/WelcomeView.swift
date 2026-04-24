import SwiftUI

struct WelcomeView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color(hex: "1A1A3E").ignoresSafeArea()

            VStack {
                TabView(selection: $currentPage) {
                    welcomePage(tag: 0)
                    privacyPage(tag: 1)
                    securityPage(tag: 2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Button(action: {
                    if currentPage < 2 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(Color(hex: "1A1A3E"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "F2E4BF"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }

    private func welcomePage(tag: Int) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color(hex: "F2E4BF"))
            Text("SafeCycle")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Text("Your body. Your data. Your control.")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Text("A private period tracker that keeps your health data where it belongs — on your phone.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .tag(tag)
    }

    private func privacyPage(tag: Int) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "icloud.slash")
                .font(.system(size: 64))
                .foregroundStyle(Color(hex: "7EC8A0"))
            Text("No Cloud. No Account.")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 16) {
                privacyRow(icon: "xmark.circle.fill", text: "No cloud storage")
                privacyRow(icon: "xmark.circle.fill", text: "No account required")
                privacyRow(icon: "xmark.circle.fill", text: "No data sharing")
                privacyRow(icon: "checkmark.circle.fill", text: "100% local storage")
                privacyRow(icon: "checkmark.circle.fill", text: "AES-256 encryption")
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .tag(tag)
    }

    private func securityPage(tag: Int) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundStyle(Color(hex: "F4A261"))
            Text("Protect Your Privacy")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 16) {
                privacyRow(icon: "faceid", text: "Face ID / Touch ID lock")
                privacyRow(icon: "lock.shield", text: "Custom PIN protection")
                privacyRow(icon: "eye.slash", text: "Stealth mode with calculator disguise")
                privacyRow(icon: "bell.slash", text: "Disguised notifications")
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .tag(tag)
    }

    private func privacyRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(hex: "F2E4BF"))
                .frame(width: 24)
            Text(text)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
    }
}

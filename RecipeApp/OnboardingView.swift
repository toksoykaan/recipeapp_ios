import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "fork.knife.circle.fill",
            title: "Welcome to RecipeVault",
            description: "Your all-in-one recipe management app. Create, organize, and discover amazing recipes.",
            color: .primaryOrange
        ),
        OnboardingPage(
            icon: "camera.fill",
            title: "Scan & Import Recipes",
            description: "Use OCR to scan recipes from cookbooks or import from your favorite websites.",
            color: .secondaryGreen
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "AI-Powered Features",
            description: "Generate recipes with AI, get smart suggestions, and automatic nutrition tracking.",
            color: .accentPurple
        ),
        OnboardingPage(
            icon: "calendar",
            title: "Plan Your Meals",
            description: "Organize your week with meal planning and auto-generate grocery lists.",
            color: .info
        )
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack {
                Spacer()

                if currentPage == pages.count - 1 {
                    Button(action: {
                        HapticFeedback.success.generate()
                        hasCompletedOnboarding = true
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.primaryOrange, .secondaryGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(.cornerRadiusMedium)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 80)
                }
            }
            .animation(.easeInOut, value: currentPage)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animate = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(animate ? 1.1 : 1.0)

                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
                    .scaleEffect(animate ? 1.0 : 0.8)
            }

            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(animate ? 1 : 0)

            Text(page.description)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(animate ? 1 : 0)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animate = true
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}

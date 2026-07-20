import SwiftUI

struct EncounterAnimationView: View {
    let profiles: [EncounteredProfile]
    let onComplete: () -> Void

    @State private var currentIndex = 0
    @State private var isAnimating = false
    @State private var showCard = false

    var body: some View {
        NavigationStack {
            ZStack {
                NintendoTheme.homeBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    if currentIndex < profiles.count {
                        profileCard
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        completionView
                    }

                    Spacer()

                    if currentIndex < profiles.count {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex += 1
                                showCard = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showCard = true
                                }
                            }
                        } label: {
                            Text("次へ")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(NintendoTheme.nintendoRed)
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("すれちがった！")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        onComplete()
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
        }
        .onAppear {
            showCard = true
        }
    }

    private var profileCard: some View {
        VStack(spacing: 24) {
            ProfileAvatarView(
                foxAvatar: profiles[currentIndex].profile.foxAvatar,
                size: 120,
                showsBorder: true
            )
            .scaleEffect(showCard ? 1 : 0.5)
            .opacity(showCard ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCard)

            VStack(spacing: 12) {
                Text(profiles[currentIndex].profile.trimmedNickname)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text(profiles[currentIndex].profile.greetingMessage)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                if profiles[currentIndex].profile.prefecture != "未設定" {
                    Text(profiles[currentIndex].profile.prefecture)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(NintendoTheme.nintendoYellow)
                }

                if profiles[currentIndex].encounterCount > 1 {
                    Text("\(profiles[currentIndex].encounterCount)回目のすれちがい")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(NintendoTheme.streetPassGreen)
                }
            }
            .opacity(showCard ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: showCard)
        }
        .padding(.horizontal, 24)
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(NintendoTheme.streetPassGreen)
                .scaleEffect(isAnimating ? 1 : 0.5)
                .opacity(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)

            VStack(spacing: 12) {
                Text("すべて確認しました！")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(profiles.count)人とすれちがいました")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: isAnimating)

            Button {
                onComplete()
            } label: {
                Text("完了")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(NintendoTheme.streetPassGreen)
                    )
            }
            .padding(.horizontal, 24)
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)
        }
        .padding(.horizontal, 24)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    EncounterAnimationView(
        profiles: [
            EncounteredProfile(profile: UserProfile.default),
            EncounteredProfile(profile: UserProfile.default)
        ]
    ) {
        print("Complete")
    }
}

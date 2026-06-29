import SwiftUI

struct ProfileRegistrationView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var draft = UserProfile.default
    @State private var showValidationAlert = false
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            ZStack {
                NintendoTheme.homeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        welcomeCard
                        profileCard
                        editForm
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("プロフィール登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("登録") {
                        saveProfile()
                    }
                    .font(.system(.body, design: .rounded, weight: .heavy))
                    .disabled(!draft.isValid)
                }
            }
            .alert("ニックネームを入力してください", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .environmentObject(profileStore)
            }
        }
    }

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("はじめに", systemImage: "star.fill")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(NintendoTheme.nintendoYellow)

            Text("すれちがいアプリへようこそ！まずはプロフィールを登録しましょう。近くを歩いた人に、この情報が表示されます。")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground(stroke: NintendoTheme.nintendoYellow.opacity(0.45)))
    }

    private var profileCard: some View {
        VStack(spacing: 16) {
            ProfileAvatarView(foxAvatar: draft.foxAvatar, size: 120)

            Text(draft.trimmedNickname.isEmpty ? "ニックネーム未設定" : draft.trimmedNickname)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(draft.greetingMessage.isEmpty ? "ひとことを設定しよう" : draft.greetingMessage)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(cardBackground(stroke: NintendoTheme.streetPassGreen.opacity(0.5)))
    }

    private var editForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("ニックネーム", limit: "12文字まで")
                TextField("例：たびびと", text: $draft.nickname)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(14)
                    .background(fieldBackground)
                    .onChange(of: draft.nickname) { _, newValue in
                        draft.nickname = String(newValue.prefix(12))
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("ひとこと", limit: "32文字まで")
                TextField("例：よろしくね！", text: $draft.greetingMessage, axis: .vertical)
                    .lineLimit(2 ... 3)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(14)
                    .background(fieldBackground)
                    .onChange(of: draft.greetingMessage) { _, newValue in
                        draft.greetingMessage = String(newValue.prefix(32))
                    }
            }

            VStack(alignment: .leading, spacing: 12) {
                fieldLabel("出身都道府県", limit: "47都道府県から選択")
                Picker("出身都道府県", selection: $draft.prefecture) {
                    Text("未設定").tag("未設定")
                    ForEach(prefectures, id: \.self) { prefecture in
                        Text(prefecture).tag(prefecture)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 12) {
                fieldLabel("きつねアイコン", limit: "パーツを組み合わせよう")
                FoxAvatarEditorView(config: $draft.foxAvatar)
            }
        }
        .padding(20)
        .background(cardBackground(stroke: NintendoTheme.cardBorder))
    }

    private func fieldLabel(_ title: String, limit: String?) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            if let limit {
                Text(limit)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.black.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
    }

    private func cardBackground(stroke: Color) -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(NintendoTheme.cardSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(stroke, lineWidth: 2)
            )
    }

    private func saveProfile() {
        guard draft.isValid else {
            showValidationAlert = true
            return
        }
        let profileWithUserID = UserProfile(
            userID: UUID().uuidString,
            nickname: draft.nickname,
            greetingMessage: draft.greetingMessage,
            foxAvatar: draft.foxAvatar,
            prefecture: draft.prefecture
        )
        profileStore.save(profileWithUserID)
        navigateToHome = true
    }
}

#Preview {
    ProfileRegistrationView()
        .environmentObject(ProfileStore())
}

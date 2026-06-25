import SwiftUI

let prefectures = [
    "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
    "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
    "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県",
    "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県",
    "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県",
    "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
    "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
]

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileStore: ProfileStore

    @State private var isEditing = false
    @State private var draft = UserProfile.default
    @State private var showValidationAlert = false

    private var displayProfile: UserProfile {
        isEditing ? draft : profileStore.profile
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NintendoTheme.homeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        profileCard
                        if isEditing {
                            editForm
                        } else {
                            previewCard
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("保存") {
                            saveProfile()
                        }
                        .font(.system(.body, design: .rounded, weight: .heavy))
                        .disabled(!draft.isValid)
                    } else {
                        Button("編集") {
                            beginEditing()
                        }
                        .font(.system(.body, design: .rounded, weight: .heavy))
                    }
                }
            }
            .alert("ニックネームを入力してください", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .onAppear {
            if !profileStore.profile.isValid {
                beginEditing()
            }
        }
    }

    private var profileCard: some View {
        VStack(spacing: 16) {
            ProfileAvatarView(foxAvatar: displayProfile.foxAvatar, size: 120)

            Text(displayProfile.trimmedNickname.isEmpty ? "ニックネーム未設定" : displayProfile.trimmedNickname)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(displayProfile.greetingMessage.isEmpty ? "ひとことを設定しよう" : displayProfile.greetingMessage)
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

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("すれ違いで共有される情報", systemImage: "dot.radiowaves.left.and.right")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(NintendoTheme.nintendoYellow)

            Text("近くを歩いた人に、このニックネーム・アイコン・ひとこと・出身地が表示されます。ゲーム機能追加時にアイテムや実績もここから見られる予定です。")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground(stroke: NintendoTheme.cardBorder))
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

            if isEditing {
                Button("キャンセル") {
                    cancelEditing()
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(cardBackground(stroke: NintendoTheme.nintendoYellow.opacity(0.45)))
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

    private func beginEditing() {
        draft = profileStore.profile
        isEditing = true
    }

    private func cancelEditing() {
        draft = profileStore.profile
        isEditing = false
    }

    private func saveProfile() {
        guard draft.isValid else {
            showValidationAlert = true
            return
        }
        profileStore.save(draft)
        isEditing = false
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileStore())
}


import SwiftUI

struct EncounteredListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: EncounteredProfilesStore
    @State private var showingDeleteAlert = false
    @State private var profileToDelete: EncounteredProfile?

    var body: some View {
        NavigationStack {
            ZStack {
                NintendoTheme.homeBackground
                    .ignoresSafeArea()

                if store.encounteredProfiles.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle("すれちがった人")
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

                if !store.encounteredProfiles.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("全削除") {
                            showingDeleteAlert = true
                        }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(.red)
                    }
                }
            }
            .alert("すべてのプロフィールを削除しますか？", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) {
                    store.removeAll()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.4))

            Text("まだすれちがっていません")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            Text("ポケットに入れたまま歩くと、\n近くを歩いている人とつながります")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var listContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                statsHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                if !store.dailyStats.isEmpty {
                    dailyStatsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }

                LazyVStack(spacing: 12) {
                    ForEach(Array(store.encounteredProfiles.enumerated()), id: \.element.id) { index, profile in
                        ProfileCard(profile: profile) {
                            store.confirmProfile(at: index)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                profileToDelete = profile
                                showingDeleteAlert = true
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .alert("このプロフィールを削除しますか？", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let profileToDelete {
                    if let index = store.encounteredProfiles.firstIndex(where: { $0.id == profileToDelete.id }) {
                        store.removeProfile(at: index)
                    }
                }
            }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "今日",
                value: "\(store.todayCount)人",
                icon: "sun.max.fill",
                color: NintendoTheme.nintendoYellow
            )

            StatCard(
                title: "合計",
                value: "\(store.totalCount)人",
                icon: "person.2.fill",
                color: NintendoTheme.streetPassGreen
            )
        }
    }

    private var dailyStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別のすれちがい")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.dailyStats.prefix(7)) { stat in
                        DailyStatCard(stat: stat)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.2))
        )
    }
}

struct ProfileCard: View {
    let profile: EncounteredProfile
    let onConfirm: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ProfileAvatarView(
                foxAvatar: profile.profile.foxAvatar,
                size: 56,
                showsBorder: true
            )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(profile.profile.trimmedNickname)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    if profile.encounterCount > 1 {
                        Text(profile.encounterCountText)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(NintendoTheme.nintendoYellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(NintendoTheme.nintendoYellow.opacity(0.2))
                            )
                    }
                }

                Text(profile.profile.greetingMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)

                if profile.profile.prefecture != "未設定" {
                    Text(profile.profile.prefecture)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(NintendoTheme.nintendoYellow)
                }

                Text(profile.relativeTime)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            if !profile.isConfirmed {
                Button(action: onConfirm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(NintendoTheme.streetPassGreen)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(NintendoTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(profile.isConfirmed ? NintendoTheme.streetPassGreen.opacity(0.5) : NintendoTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.2))
        )
    }
}

struct DailyStatCard: View {
    let stat: DailyStat

    var body: some View {
        VStack(spacing: 8) {
            Text(stat.formattedDate)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(stat.isToday ? NintendoTheme.nintendoYellow : .white.opacity(0.8))

            Text("\(stat.count)人")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            if stat.isToday {
                Text("今日")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(NintendoTheme.nintendoYellow)
            }
        }
        .frame(width: 70)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(stat.isToday ? NintendoTheme.nintendoYellow.opacity(0.2) : Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(stat.isToday ? NintendoTheme.nintendoYellow.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
    }
}

#Preview {
    EncounteredListView()
        .environmentObject(EncounteredProfilesStore())
}

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var encounteredStore: EncounteredProfilesStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var pedometer = PedometerService()
    @StateObject private var bleService = BLEService()
    @State private var sparklePhase = false
    @State private var showsProfile = false
    @State private var showsEncounteredList = false
    @State private var showsCollectionList = false

    var body: some View {
        ZStack {
            backgroundLayer
            sparkleLayer
            contentLayer
        }
        .onAppear {
            sparklePhase = true
            pedometer.startTracking()
            bleService.startScanning()
            bleService.startAdvertising(with: profileStore.profile)
        }
        .onDisappear {
            pedometer.stopTracking()
            bleService.stopScanning()
            bleService.stopAdvertising()
        }
        .onChange(of: profileStore.profile) { _, newProfile in
            bleService.startAdvertising(with: newProfile)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didEncounterProfile)) { notification in
            if let profile = notification.userInfo?["profile"] as? UserProfile,
               let peerID = notification.userInfo?["peerID"] as? String,
               let remoteUserID = notification.userInfo?["remoteUserID"] as? String {
                encounteredStore.addProfile(profile, peerID: peerID, remoteUserID: remoteUserID)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // フォアグラウンド：アドバタイズ開始
                bleService.startAdvertising(with: profileStore.profile)
            case .background, .inactive:
                // バックグラウンド：アドバタイズ停止、スキャンのみ継続
                bleService.stopAdvertising()
            @unknown default:
                break
            }
        }
        .sheet(isPresented: $showsProfile) {
            ProfileView()
                .environmentObject(profileStore)
        }
        .sheet(isPresented: $showsEncounteredList) {
            EncounteredListView()
        }
        .sheet(isPresented: $showsCollectionList) {
            CollectionListView()
        }
    }

    private var backgroundLayer: some View {
        NintendoTheme.homeBackground
            .ignoresSafeArea()
            .overlay(
                RadialGradient(
                    colors: [NintendoTheme.streetPassGlow.opacity(0.18), .clear],
                    center: .center,
                    startRadius: 40,
                    endRadius: 320
                )
                .offset(y: 80)
            )
    }

    private var sparkleLayer: some View {
        ZStack {
            ForEach(0 ..< 12, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 3) ? "star.fill" : "circle.fill")
                    .font(.system(size: index.isMultiple(of: 3) ? 10 : 4))
                    .foregroundStyle(
                        index.isMultiple(of: 2)
                            ? NintendoTheme.nintendoYellow.opacity(0.7)
                            : Color.white.opacity(0.5)
                    )
                    .offset(sparkleOffset(for: index))
                    .opacity(sparklePhase ? 0.9 : 0.3)
                    .animation(
                        .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.12),
                        value: sparklePhase
                    )
            }
        }
        .allowsHitTesting(false)
    }

    private var contentLayer: some View {
        ScrollView {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                StepCounterHeaderView(
                    steps: pedometer.todaySteps,
                    stepsUntilNextMilestone: pedometer.stepsUntilNextMilestone,
                    milestoneProgress: pedometer.milestoneProgress,
                    completedMilestones: pedometer.completedMilestones,
                    statusMessage: pedometer.statusMessage
                )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                Spacer(minLength: 24)

                VStack(spacing: 20) {
                    PassingRadarView()

                    statusBadge

                    collectionButton
                }

                Spacer(minLength: 32)

                bottomHint
                    .padding(.horizontal, 24)

                Spacer(minLength: 16)

                Button {
                    showsProfile = true
                } label: {
                    HStack(spacing: 12) {
                        ProfileAvatarView(
                            foxAvatar: profileStore.profile.foxAvatar,
                            size: 44,
                            showsBorder: true
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("プロフィール")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            Text(profileStore.profile.trimmedNickname)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(NintendoTheme.cardSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(NintendoTheme.cardBorder, lineWidth: 1)
                        )
                )
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Label("すれちがい", systemImage: "dot.radiowaves.left.and.right")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(NintendoTheme.nintendoRed.opacity(0.85))
                )

            Spacer()
        }
    }

    private var statusBadge: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Circle()
                    .fill(NintendoTheme.streetPassGreen)
                    .frame(width: 10, height: 10)
                    .shadow(color: NintendoTheme.streetPassGlow, radius: 4)
                    .overlay(
                        Circle()
                            .stroke(NintendoTheme.streetPassGlow, lineWidth: 2)
                            .scaleEffect(1.6)
                            .opacity(0.6)
                    )

                Text("すれ違い通信中…")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text("近くを歩いている人を探しています")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))

            if encounteredStore.totalCount > 0 {
                HStack(spacing: 4) {
                    Text("すれちがった人: \(encounteredStore.totalCount)人")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(NintendoTheme.nintendoYellow)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(NintendoTheme.nintendoYellow)
                }
            } else {
                HStack(spacing: 4) {
                    Text("すれちがった人を確認")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(NintendoTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(NintendoTheme.streetPassGreen.opacity(0.5), lineWidth: 2)
                )
        )
        .onTapGesture {
            showsEncounteredList = true
        }
    }

    private var collectionButton: some View {
        Button {
            showsCollectionList = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.title3)
                    .foregroundStyle(NintendoTheme.nintendoYellow)

                Text("コレクション")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                if encounteredStore.totalCount > 0 {
                    Text("\(encounteredStore.totalCount)")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(NintendoTheme.nintendoYellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(NintendoTheme.nintendoYellow.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.2))
            )
        }
        .buttonStyle(.plain)
    }

    private var bottomHint: some View {
        HStack(spacing: 10) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.title3)
                .foregroundStyle(NintendoTheme.nintendoYellow)

            Text("ポケットに入れたまま歩くと、すれ違った人とつながります")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.15))
        )
    }

    private func sparkleOffset(for index: Int) -> CGSize {
        let angles = [0, 30, 60, 90, 120, 150, 200, 240, 280, 310, 340, 20]
        let radius: CGFloat = 140 + CGFloat(index % 4) * 18
        let angle = Double(angles[index % angles.count]) * Double.pi / 180
        return CGSize(
            width: cos(angle) * Double(radius),
            height: sin(angle) * Double(radius) - 40
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(ProfileStore())
}

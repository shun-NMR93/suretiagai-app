import SwiftUI

struct StepCounterHeaderView: View {
    let steps: Int
    let stepsUntilNextMilestone: Int
    let milestoneProgress: Double
    let completedMilestones: Int
    let statusMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "figure.walk")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(NintendoTheme.nintendoYellow)
                    .symbolEffect(.bounce, options: .repeating)

                Text("今日の歩数")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(NintendoTheme.nintendoYellow)
                    .multilineTextAlignment(.center)
            } else {
                Text(steps.formatted(.number.grouping(.automatic)))
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(NintendoTheme.stepNumberGradient)
                    .shadow(color: NintendoTheme.streetPassGlow.opacity(0.5), radius: 12, y: 4)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("歩")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .offset(y: -8)

                milestoneProgressBar
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(NintendoTheme.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(NintendoTheme.cardBorder, lineWidth: 2)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
    }

    private var milestoneProgressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Label("1,000歩ごと", systemImage: "gift.fill")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(NintendoTheme.nintendoYellow)

                Spacer()

                if completedMilestones > 0 {
                    Text("達成 \(completedMilestones) 回")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(NintendoTheme.streetPassGlow)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 12)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [NintendoTheme.nintendoYellow, NintendoTheme.streetPassGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * milestoneProgress, height: 12)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: milestoneProgress)
                }
            }
            .frame(height: 12)

            HStack {
                Text("\(StepMilestone.stepsInCurrentBlock(for: steps).formatted()) / \(StepMilestone.interval.formatted()) 歩")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))

                Spacer()

                Text("次まで あと \(stepsUntilNextMilestone.formatted()) 歩")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(.top, 4)
    }
}

#Preview {
    ZStack {
        NintendoTheme.homeBackground.ignoresSafeArea()
        StepCounterHeaderView(
            steps: 2_420,
            stepsUntilNextMilestone: 580,
            milestoneProgress: 0.42,
            completedMilestones: 2,
            statusMessage: nil
        )
        .padding()
    }
}

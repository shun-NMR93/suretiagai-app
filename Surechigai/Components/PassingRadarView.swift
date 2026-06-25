import SwiftUI

struct PassingRadarView: View {
    private let rippleCount = 4
    private let radarSize: CGFloat = 280

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            radarContent(time: time)
        }
        .frame(width: radarSize, height: radarSize)
        .accessibilityLabel("すれ違い通信のレーダー")
        .accessibilityValue("通信中")
    }

    @ViewBuilder
    private func radarContent(time: TimeInterval) -> some View {
        ZStack {
            ForEach(0 ..< rippleCount, id: \.self) { index in
                rippleRing(index: index, time: time)
            }

            radarGrid
            centerPulse(time: time)
        }
    }

    private var radarGrid: some View {
        ZStack {
            Circle()
                .stroke(NintendoTheme.streetPassGreen.opacity(0.35), lineWidth: 2)

            ForEach([0.33, 0.66], id: \.self) { scale in
                Circle()
                    .stroke(NintendoTheme.streetPassGreen.opacity(0.18), lineWidth: 1)
                    .scaleEffect(scale)
            }
        }
    }

    private func rippleRing(index: Int, time: TimeInterval) -> some View {
        let duration = 2.4
        let offset = Double(index) * (duration / Double(rippleCount))
        let phase = (time + offset).truncatingRemainder(dividingBy: duration) / duration
        let scale = 0.35 + phase * 0.75
        let opacity = max(0, 0.75 * (1 - phase))

        return Circle()
            .stroke(
                NintendoTheme.streetPassGlow.opacity(opacity),
                lineWidth: 3 - CGFloat(phase) * 1.5
            )
            .scaleEffect(scale)
            .opacity(opacity)
    }

    private func centerPulse(time: TimeInterval) -> some View {
        let pulse = 0.85 + 0.15 * sin(time * 4)
        return ZStack {
            Circle()
                .fill(NintendoTheme.streetPassGlow.opacity(0.35))
                .frame(width: 36 * pulse, height: 36 * pulse)
                .blur(radius: 6)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, NintendoTheme.streetPassGreen],
                        center: .center,
                        startRadius: 0,
                        endRadius: 14
                    )
                )
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                )
                .shadow(color: NintendoTheme.streetPassGlow, radius: 8)
        }
    }
}

#Preview {
    ZStack {
        NintendoTheme.homeBackground.ignoresSafeArea()
        PassingRadarView()
    }
}

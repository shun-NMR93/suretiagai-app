import SwiftUI

struct FoxAvatarView: View {
    let config: FoxAvatarConfig
    var size: CGFloat = 88
    var showsBorder: Bool = true

    private var avatar: FoxAvatarConfig {
        config.clamped()
    }

    private var fur: FoxFurPalette {
        FoxPartCatalog.furPalette(index: avatar.furColorIndex)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.62, green: 0.82, blue: 0.98),
                            Color(red: 0.38, green: 0.58, blue: 0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            ZStack {
                tailLayer
                bodyLayer
                headLayer
                cheekLayer
                eyeLayer
                noseLayer
                mouthLayer
                accessoryLayer
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            if showsBorder {
                Circle()
                    .stroke(Color.white.opacity(0.9), lineWidth: max(3, size * 0.04))
            }
        }
        .shadow(color: fur.main.opacity(0.35), radius: size * 0.08, y: size * 0.04)
    }

    // MARK: - Body

    private var tailLayer: some View {
        FoxTailShape()
            .fill(fur.main)
            .frame(width: size * 0.42, height: size * 0.5)
            .overlay(FoxTailShape().stroke(fur.main.opacity(0.5), lineWidth: size * 0.01))
            .rotationEffect(.degrees(-25))
            .offset(x: -size * 0.28, y: size * 0.18)
    }

    private var bodyLayer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.14, style: .continuous)
                .fill(fur.main)
                .frame(width: size * 0.44, height: size * 0.38)
                .offset(y: size * 0.2)

            Ellipse()
                .fill(fur.belly)
                .frame(width: size * 0.3, height: size * 0.24)
                .offset(y: size * 0.22)

            RoundedRectangle(cornerRadius: size * 0.08)
                .fill(fur.main)
                .frame(width: size * 0.1, height: size * 0.18)
                .offset(x: -size * 0.28, y: size * 0.16)
            RoundedRectangle(cornerRadius: size * 0.08)
                .fill(fur.main)
                .frame(width: size * 0.1, height: size * 0.18)
                .offset(x: size * 0.28, y: size * 0.16)

            Ellipse()
                .fill(fur.main.opacity(0.9))
                .frame(width: size * 0.12, height: size * 0.08)
                .offset(x: -size * 0.14, y: size * 0.36)
            Ellipse()
                .fill(fur.main.opacity(0.9))
                .frame(width: size * 0.12, height: size * 0.08)
                .offset(x: size * 0.14, y: size * 0.36)

            pawPads
        }
    }

    private var pawPads: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.25, green: 0.18, blue: 0.2).opacity(0.55))
                .frame(width: size * 0.07, height: size * 0.05)
                .offset(x: -size * 0.14, y: size * 0.37)
            Ellipse()
                .fill(Color(red: 0.25, green: 0.18, blue: 0.2).opacity(0.55))
                .frame(width: size * 0.07, height: size * 0.05)
                .offset(x: size * 0.14, y: size * 0.37)
        }
    }

    // MARK: - Head

    private var headLayer: some View {
        ZStack {
            Circle()
                .fill(fur.main)
                .frame(width: size * 0.56, height: size * 0.56)
                .offset(y: -size * 0.06)

            foxEar(side: -1)
            foxEar(side: 1)
        }
    }

    private func foxEar(side: CGFloat) -> some View {
        ZStack {
            FoxEarShape()
                .fill(fur.main)
                .frame(width: size * 0.2, height: size * 0.26)
            FoxEarShape()
                .fill(fur.innerEar)
                .frame(width: size * 0.12, height: size * 0.16)
                .offset(y: size * 0.03)
        }
        .rotationEffect(.degrees(side < 0 ? -18 : 18))
        .offset(x: side * size * 0.28, y: -size * 0.3)
    }

    @ViewBuilder
    private var cheekLayer: some View {
        if avatar.cheekStyle > 0 {
            let opacity = avatar.cheekStyle == 2 ? 0.5 : 0.32
            HStack(spacing: size * 0.28) {
                Circle()
                    .fill(Color(red: 1, green: 0.45, blue: 0.48).opacity(opacity))
                    .frame(width: size * 0.12)
                Circle()
                    .fill(Color(red: 1, green: 0.45, blue: 0.48).opacity(opacity))
                    .frame(width: size * 0.12)
            }
            .offset(y: -size * 0.02)
        }
    }

    private var eyeLayer: some View {
        HStack(spacing: size * 0.18) {
            foxEye(style: avatar.eyeStyle, wink: false)
            foxEye(style: avatar.eyeStyle, wink: avatar.eyeStyle == 4)
        }
        .offset(y: -size * 0.08)
    }

    @ViewBuilder
    private func foxEye(style: Int, wink: Bool) -> some View {
        if wink {
            ArcSmile(upward: false)
                .stroke(Color.black.opacity(0.75), style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round))
                .frame(width: size * 0.14, height: size * 0.08)
                .rotationEffect(.degrees(180))
        } else if style == 4 {
            Circle()
                .fill(Color.black.opacity(0.85))
                .frame(width: size * 0.11)
                .overlay(
                    Circle().fill(.white).frame(width: size * 0.035)
                        .offset(x: size * 0.02, y: -size * 0.025)
                )
        } else {
            switch style {
            case 0:
                Circle()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: size * 0.11)
                    .overlay(
                        Circle().fill(.white).frame(width: size * 0.035)
                            .offset(x: size * 0.02, y: -size * 0.025)
                    )
            case 1:
                ArcSmile(upward: true)
                    .stroke(Color.black.opacity(0.75), style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round))
                    .frame(width: size * 0.14, height: size * 0.08)
            case 2:
                Ellipse()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: size * 0.1, height: size * 0.14)
                    .overlay(
                        Circle().fill(.white).frame(width: size * 0.04)
                            .offset(x: size * 0.015, y: -size * 0.03)
                    )
            case 3:
                ZStack {
                    Circle().fill(Color.black.opacity(0.85)).frame(width: size * 0.1)
                    Circle().fill(.white).frame(width: size * 0.038)
                        .offset(x: size * 0.018, y: -size * 0.028)
                    Image(systemName: "sparkle")
                        .font(.system(size: size * 0.05, weight: .bold))
                        .foregroundStyle(NintendoTheme.nintendoYellow)
                        .offset(x: -size * 0.04, y: -size * 0.04)
                }
            default:
                Circle()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: size * 0.1)
            }
        }
    }

    private var noseLayer: some View {
        FoxNoseShape()
            .fill(Color(red: 0.2, green: 0.12, blue: 0.14))
            .frame(width: size * 0.1, height: size * 0.07)
            .offset(y: size * 0.02)
    }

    @ViewBuilder
    private var mouthLayer: some View {
        Group {
            switch avatar.mouthStyle {
            case 0:
                ArcSmile(upward: true)
                    .stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: size * 0.022, lineCap: .round))
                    .frame(width: size * 0.18, height: size * 0.08)
            case 1:
                Ellipse()
                    .fill(Color(red: 0.75, green: 0.25, blue: 0.32))
                    .frame(width: size * 0.1, height: size * 0.08)
                    .offset(y: size * 0.02)
            case 2:
                Ellipse()
                    .fill(Color(red: 0.92, green: 0.45, blue: 0.55))
                    .frame(width: size * 0.08, height: size * 0.1)
                    .offset(y: size * 0.04)
            case 3:
                Text(":3")
                    .font(.system(size: size * 0.12, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.65))
            default:
                Capsule()
                    .fill(Color.black.opacity(0.55))
                    .frame(width: size * 0.08, height: size * 0.035)
            }
        }
        .offset(y: size * 0.1)
    }

    @ViewBuilder
    private var accessoryLayer: some View {
        switch avatar.accessory {
        case 1:
            RoundedRectangle(cornerRadius: size * 0.02)
                .stroke(Color.black.opacity(0.75), lineWidth: size * 0.022)
                .frame(width: size * 0.38, height: size * 0.12)
                .offset(y: -size * 0.08)
        case 2:
            Capsule()
                .fill(Color.black.opacity(0.78))
                .frame(width: size * 0.4, height: size * 0.1)
                .offset(y: -size * 0.08)
        case 3:
            earring(at: -1)
        case 4:
            earring(at: 1)
        case 5:
            earring(at: -1)
            earring(at: 1)
        default:
            EmptyView()
        }
    }

    private func earring(at side: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [NintendoTheme.nintendoYellow, Color(red: 0.9, green: 0.6, blue: 0.1)],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.04
                )
            )
            .frame(width: size * 0.07, height: size * 0.07)
            .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1))
            .offset(x: side * size * 0.3, y: -size * 0.22)
    }
}

// MARK: - Shapes

private struct FoxEarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct FoxTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX * 0.7, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY * 0.6)
        )
        path.closeSubpath()
        return path
    }
}

private struct FoxNoseShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct ArcSmile: Shape {
    let upward: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let y = upward ? rect.maxY * 0.85 : rect.minY * 0.15
        path.addArc(
            center: CGPoint(x: rect.midX, y: y),
            radius: rect.width * 0.45,
            startAngle: .degrees(upward ? 200 : 20),
            endAngle: .degrees(upward ? 340 : 160),
            clockwise: !upward
        )
        return path
    }
}

#Preview {
    FoxAvatarView(config: .default, size: 140)
}

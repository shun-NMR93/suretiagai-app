import SwiftUI

struct FoxAvatarEditorView: View {
    @Binding var config: FoxAvatarConfig

    var body: some View {
        VStack(spacing: 20) {
            FoxAvatarView(config: config, size: 130)

            VStack(spacing: 16) {
                partPicker(
                    title: "毛の色",
                    labels: FoxPartCatalog.furColorLabels,
                    selection: $config.furColorIndex,
                    preview: { index in
                        Circle()
                            .fill(FoxPartCatalog.furPalette(index: index).main)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 2))
                    }
                )

                partPicker(
                    title: "顔の形",
                    labels: FoxPartCatalog.faceShapeLabels,
                    selection: $config.faceShape,
                    preview: { index in
                        miniPreview { $0.faceShape = index }
                    }
                )

                partPicker(
                    title: "耳の形",
                    labels: FoxPartCatalog.earShapeLabels,
                    selection: $config.earShape,
                    preview: { index in
                        miniPreview { $0.earShape = index }
                    }
                )

                partPicker(
                    title: "体の形",
                    labels: FoxPartCatalog.bodyShapeLabels,
                    selection: $config.bodyShape,
                    preview: { index in
                        miniPreview { $0.bodyShape = index }
                    }
                )

                partPicker(
                    title: "目",
                    labels: FoxPartCatalog.eyeStyleLabels,
                    selection: $config.eyeStyle,
                    preview: { index in
                        miniPreview { $0.eyeStyle = index }
                    }
                )

                partPicker(
                    title: "口",
                    labels: FoxPartCatalog.mouthStyleLabels,
                    selection: $config.mouthStyle,
                    preview: { index in
                        miniPreview { $0.mouthStyle = index }
                    }
                )

                partPicker(
                    title: "ほっぺ",
                    labels: FoxPartCatalog.cheekStyleLabels,
                    selection: $config.cheekStyle,
                    preview: { index in
                        miniPreview { $0.cheekStyle = index }
                    }
                )
            }
        }
        .onChange(of: config) { _, newValue in
            config = newValue.clamped()
        }
    }

    private func miniPreview(_ mutate: (inout FoxAvatarConfig) -> Void) -> some View {
        var previewConfig = config.clamped()
        mutate(&previewConfig)
        return FoxAvatarView(config: previewConfig, size: 48, showsBorder: false)
    }

    private func partPicker<Preview: View>(
        title: String,
        labels: [String],
        selection: Binding<Int>,
        @ViewBuilder preview: @escaping (Int) -> Preview
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text(labels[selection.wrappedValue.clamped(to: labels.count)])
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(NintendoTheme.nintendoYellow)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0 ..< labels.count, id: \.self) { index in
                        Button {
                            selection.wrappedValue = index
                        } label: {
                            VStack(spacing: 6) {
                                preview(index)
                                    .frame(width: 48, height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.black.opacity(0.2))
                                    )
                                Text(labels[index])
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.85))
                                    .lineLimit(1)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(selection.wrappedValue == index ? NintendoTheme.streetPassGreen.opacity(0.35) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                selection.wrappedValue == index ? NintendoTheme.nintendoYellow : Color.white.opacity(0.2),
                                                lineWidth: selection.wrappedValue == index ? 2 : 1
                                            )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private extension Int {
    func clamped(to count: Int) -> Int {
        guard count > 0 else { return 0 }
        return Swift.min(Swift.max(self, 0), count - 1)
    }
}

#Preview {
    ZStack {
        NintendoTheme.homeBackground.ignoresSafeArea()
        ScrollView {
            FoxAvatarEditorView(config: .constant(.default))
                .padding()
        }
    }
}

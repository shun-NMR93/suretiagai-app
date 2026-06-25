import SwiftUI

struct ProfileAvatarView: View {
    let foxAvatar: FoxAvatarConfig
    var size: CGFloat = 88
    var showsBorder: Bool = true

    var body: some View {
        FoxAvatarView(config: foxAvatar, size: size, showsBorder: showsBorder)
    }
}

#Preview {
    ProfileAvatarView(foxAvatar: .default, size: 120)
}

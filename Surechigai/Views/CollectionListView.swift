import SwiftUI

struct CollectionListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = EncounteredProfilesStore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                NintendoTheme.homeBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        statsHeader
                            .padding(.horizontal, 20)
                            .padding(.top, 12)

                        prefectureGrid
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("コレクション")
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
            }
        }
    }
    
    private var statsHeader: some View {
        VStack(spacing: 12) {
            Text("出身地コレクション")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            
            Text("すれちがった人の出身都道府県")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    private var prefectureGrid: some View {
        let groupedPrefectures = Dictionary(grouping: prefectures.enumerated()) { $0.offset / 7 }
        
        return VStack(spacing: 12) {
            ForEach(groupedPrefectures.keys.sorted(), id: \.self) { row in
                if let items = groupedPrefectures[row] {
                    HStack(spacing: 8) {
                        ForEach(items, id: \.offset) { index, prefecture in
                            PrefectureCell(
                                prefecture: prefecture,
                                count: prefectureCount(for: prefecture)
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func prefectureCount(for prefecture: String) -> Int {
        store.encounteredProfiles.filter { $0.profile.prefecture == prefecture }.count
    }
}

struct PrefectureCell: View {
    let prefecture: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(prefecture)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(count > 0 ? .white : .white.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(NintendoTheme.nintendoYellow)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(count > 0 ? NintendoTheme.nintendoYellow.opacity(0.2) : Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(count > 0 ? NintendoTheme.nintendoYellow.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
    }
}

#Preview {
    CollectionListView()
}

import SwiftUI

@main
struct SurechigaiApp: App {
    @StateObject private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(profileStore)
                .preferredColorScheme(.light)
        }
    }
}

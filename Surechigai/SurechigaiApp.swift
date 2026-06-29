import SwiftUI

@main
struct SurechigaiApp: App {
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var encounteredStore = EncounteredProfilesStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if profileStore.hasProfile {
                    HomeView()
                        .environmentObject(profileStore)
                        .environmentObject(encounteredStore)
                } else {
                    ProfileRegistrationView()
                        .environmentObject(profileStore)
                        .environmentObject(encounteredStore)
                }
            }
            .preferredColorScheme(.light)
        }
    }
}

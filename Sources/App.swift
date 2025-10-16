import SwiftUI

@main
struct KanjiKanaTrainerApp: App {
    @StateObject private var env = AppEnvironment.live()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(env)
        }
    }
}

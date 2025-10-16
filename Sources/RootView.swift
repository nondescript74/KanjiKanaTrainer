import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                NavigationLink("Lesson Demo") {
                    LessonView(viewModel: LessonViewModel(id: CharacterID(script: .kana, codepoint: 12365), env: .live()))
                }
            }
            .padding()
            .navigationTitle("KanjiKana Trainer")
        }
    }
}

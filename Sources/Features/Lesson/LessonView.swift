import SwiftUI

struct LessonView: View {
    @StateObject var viewModel: LessonViewModel

    var body: some View {
        VStack {
            if let glyph = viewModel.glyph {
                Text(glyph.literal).font(.system(size: 80))
                Text(glyph.meaning.joined(separator: ", "))
                    .font(.title3).foregroundStyle(.secondary)
                Spacer()
                Button("Practice") { viewModel.startPractice() }
                    .buttonStyle(.borderedProminent)
            } else {
                ProgressView("Loading…")
            }
        }
        .task { await viewModel.loadGlyph() }
        .navigationTitle("Lesson")
    }
}

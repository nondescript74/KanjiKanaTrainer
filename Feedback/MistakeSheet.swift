import SwiftUI

/// Full-screen-ish sheet showing the stroke-by-stroke diagnosis for the last attempt.
struct MistakeSheet: View {
    let glyph: CharacterGlyph
    let diagnosis: StrokeDiagnosis
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(glyph.literal).font(.system(size: 44, weight: .bold))
                        Text("\(Int((diagnosis.score.total * 100).rounded()))%")
                            .font(.title.bold().monospacedDigit())
                        Text("order \(Int(diagnosis.score.orderAccuracy * 100))% · shape \(Int(diagnosis.score.shapeSimilarity * 100))%")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    MistakeOverlay(diagnosis: diagnosis)
                        .frame(maxWidth: 480)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("What to fix")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

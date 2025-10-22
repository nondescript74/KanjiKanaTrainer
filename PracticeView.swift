//
//  PracticeView.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 10/17/25.
//
//

import SwiftUI
import PencilKit

struct PracticeView: View {
    @StateObject var viewModel: PracticeViewModel
    @State private var drawing = PKDrawing()

    var body: some View {
        VStack(spacing: 12) {
            Text(viewModel.glyph.literal)
                .font(.system(size: adaptiveCharacterFontSize))
                .padding(.top, 20)
            Text(viewModel.glyph.meaning.joined(separator: ", "))
                .foregroundStyle(.secondary)

            CanvasRepresentable(drawing: $drawing)
                .frame(width: adaptiveCanvasSize, height: adaptiveCanvasSize)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3)))
                .padding(.horizontal)

            HStack {
                Button("Clear") { 
                    drawing = PKDrawing()
                    viewModel.clearScore()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Evaluate") { 
                    viewModel.evaluate(drawing)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            if let score = viewModel.score {
                Text("Score: \(Int(score.total * 100))%")
                    .font(.headline)
                    .foregroundStyle(score.total > 0.8 ? .green : .orange)
            }
        }
        .navigationTitle("Practice")
    }
}

#Preview {
    NavigationStack {
        PracticeView(viewModel: PracticeViewModel(
            glyph: CharacterGlyph(
                script: .kanji,
                codepoint: 0x4E00,
                literal: "一",
                readings: ["ichi", "hitotsu"],
                meaning: ["one"],
                strokes: [],
                difficulty: 1,
                components: []
            ),
            env: AppEnvironment(
                glyphs: GlyphBundleRepository(),
                progress: SwiftDataProgressStore(),
                evaluator: DefaultAttemptEvaluator()
            )
        ))
    }
}


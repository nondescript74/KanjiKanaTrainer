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
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Landscape: the canvas fills the height on the right; character, buttons and score on the left.
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 12) {
                        practiceHeader(fontSize: min(adaptiveCharacterFontSize, geometry.size.height * 0.2))
                        practiceButtons
                        practiceScore
                        Spacer(minLength: 0)
                    }
                    .frame(width: geometry.size.width * 0.38)
                    FillSquare { side in practiceCanvas(size: side) }
                }
                .padding([.vertical, .trailing])
            } else {
                VStack(spacing: 12) {
                    practiceHeader(fontSize: min(adaptiveCharacterFontSize, geometry.size.height * 0.14))
                    FillSquare { side in practiceCanvas(size: side) }
                        .padding(.horizontal)
                    practiceButtons
                    practiceScore
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Practice")
    }

    // MARK: - Layout pieces (shared by portrait and landscape)

    @ViewBuilder
    private func practiceHeader(fontSize: CGFloat) -> some View {
        Text(viewModel.glyph.literal)
            .font(.system(size: fontSize))
            .lineLimit(1)
            .minimumScaleFactor(0.4)
        Text(viewModel.glyph.meaning.joined(separator: ", "))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    private func practiceCanvas(size: CGFloat) -> some View {
        CanvasRepresentable(drawing: $drawing)
            .frame(width: size, height: size)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3)))
    }

    private var practiceButtons: some View {
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
    }

    /// Fixed-height place for the score, so the canvas never changes size when it appears.
    private var practiceScore: some View {
        ZStack {
            if let score = viewModel.score {
                ScoreFeedbackView(score: score, progress: viewModel.progress)
            }
        }
        .frame(height: 56)
    }
}

#Preview {
    if #available(iOS 16.0, *) {
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
    } else {
        // Fallback on earlier versions
    }
}


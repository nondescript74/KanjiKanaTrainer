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
                // Landscape: canvas full height on the right; character, buttons and score scroll on the left.
                HStack(alignment: .top, spacing: 16) {
                    ScrollView {
                        VStack(spacing: 12) {
                            practiceHeader
                            practiceButtons
                            practiceScore
                        }
                    }
                    .frame(maxWidth: .infinity)
                    practiceCanvas(size: max(200, min(geometry.size.height - 32, geometry.size.width * 0.6)))
                }
                .padding(.vertical)
            } else {
                VStack(spacing: 12) {
                    practiceHeader

                    // Use GeometryReader to calculate available space for canvas
                    let availableHeight = geometry.size.height - 300 // Reserve space for text, buttons, score
                    let maxCanvasSize = min(geometry.size.width - 40, availableHeight) // 40 for horizontal padding
                    let canvasSize = min(adaptiveCanvasSize, maxCanvasSize)
                    practiceCanvas(size: canvasSize)
                    practiceButtons
                    practiceScore

                    Spacer(minLength: 0) // Push everything up but allow flexibility
                }
            }
        }
        .navigationTitle("Practice")
    }

    // MARK: - Layout pieces (shared by portrait and landscape)

    @ViewBuilder
    private var practiceHeader: some View {
        Text(viewModel.glyph.literal)
            .font(.system(size: adaptiveCharacterFontSize))
            .padding(.top, 20)
        Text(viewModel.glyph.meaning.joined(separator: ", "))
            .foregroundStyle(.secondary)
    }

    private func practiceCanvas(size: CGFloat) -> some View {
        CanvasRepresentable(drawing: $drawing)
            .frame(width: size, height: size)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3)))
            .padding(.horizontal)
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

    @ViewBuilder
    private var practiceScore: some View {
        if let score = viewModel.score {
            ScoreFeedbackView(score: score, progress: viewModel.progress)
        }
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


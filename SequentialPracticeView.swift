//
//  SequentialPracticeView.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/2/25.
//

import SwiftUI
import PencilKit

struct SequentialPracticeView: View {
    @StateObject var viewModel: SequentialPracticeViewModel
    @State private var drawing = PKDrawing()
    @AppStorage("hasSeenPracticeHelp") private var hasSeenPracticeHelp = false
    @State private var showFirstTimeHelp = false
    @State private var showEvaluationTip = false
    @State private var showNavigationTip = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            let landscape = geometry.size.width > geometry.size.height
            VStack(spacing: 8) {
                // Progress indicator
                HStack {
                    Text("\(viewModel.currentNumber) of \(viewModel.totalCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    ProgressView(value: Double(viewModel.currentNumber), total: Double(viewModel.totalCount))
                        .frame(maxWidth: 150)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading character...")
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    ContentUnavailableView(
                        "Unable to Load Character",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                    Spacer()
                } else if let glyph = viewModel.currentGlyph {
                    if landscape {
                        // Landscape: the canvas fills the height on the right; everything else on the left.
                        HStack(alignment: .top, spacing: 16) {
                            VStack(spacing: 8) {
                                practiceHeader(glyph, fontSize: min(adaptiveCharacterFontSize, geometry.size.height * 0.18))
                                drawControls
                                scoreSlot
                                Spacer(minLength: 0)
                                navigationRow
                            }
                            .frame(width: geometry.size.width * 0.38)
                            FillSquare { side in practiceCanvas(size: side) }
                        }
                        .padding(.trailing)
                        .padding(.bottom, 8)
                    } else {
                        practiceHeader(glyph, fontSize: min(adaptiveCharacterFontSize, geometry.size.height * 0.12))
                        FillSquare { side in practiceCanvas(size: side) }
                            .padding(.horizontal)
                        drawControls
                        scoreSlot
                        navigationRow
                    }
                } else {
                    Spacer(minLength: 0)
                }
            }
            // Tips float over the top of the screen instead of pushing the canvas down.
            .overlay(alignment: .top) {
                VStack(spacing: 4) {
                    SequentialPracticeHelp.InlineTip(
                        icon: "hand.draw",
                        message: "Draw the character, then tap Evaluate to see your score",
                        isVisible: $showEvaluationTip
                    )
                    SequentialPracticeHelp.InlineTip(
                        icon: "arrow.left.arrow.right",
                        message: "Use Next to continue, or Previous to review earlier characters",
                        color: .green,
                        isVisible: $showNavigationTip
                    )
                }
                .padding(.top, 36)
            }
        }
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        showFirstTimeHelp = true
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .overlay {
            SequentialPracticeHelp.PracticeOverlay(isPresented: $showFirstTimeHelp)
        }
        .task {
            // Auto-show help for first-time users
            if !hasSeenPracticeHelp {
                showFirstTimeHelp = true
            }
            
            await viewModel.loadCurrentGlyph()
            // Show evaluation tip after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !showFirstTimeHelp {
                    withAnimation {
                        showEvaluationTip = true
                    }
                }
            }
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            SequentialPracticeView(viewModel: .chineseNumbers1to10(
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

// MARK: - Practice layout pieces (shared by portrait and landscape)

extension SequentialPracticeView {
    @ViewBuilder
    func practiceHeader(_ glyph: CharacterGlyph, fontSize: CGFloat) -> some View {
        HStack(spacing: 12) {
            Text(glyph.literal)
                .font(.system(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            SpeakCharacterButton(glyph: glyph)
        }
        Text(glyph.meaning.joined(separator: ", "))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        if !glyph.readings.isEmpty {
            Text(glyph.readings.joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    func practiceCanvas(size: CGFloat) -> some View {
        CanvasRepresentable(drawing: $drawing)
            .frame(width: size, height: size)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3)))
    }

    var drawControls: some View {
        HStack {
            Button("Clear") {
                drawing = PKDrawing()
                viewModel.clearScore()
            }
            .buttonStyle(.bordered)
            .practiceTooltip("Clear your drawing and start over")
            
            Spacer()
            
            Button("Evaluate") {
                viewModel.evaluate(drawing)
                // Show navigation tip after first evaluation
                if viewModel.currentIndex == 0 && !showNavigationTip {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showNavigationTip = true
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .practiceTooltip("Check how well you drew the character")
        }
        .padding(.horizontal)
    }

    /// Fixed-height place for the score, so the canvas never changes size when it appears.
    var scoreSlot: some View {
        ZStack {
            if let score = viewModel.score {
                ScoreFeedbackView(score: score, progress: viewModel.progress)
            }
        }
        .frame(height: 56)
    }

    @ViewBuilder
    var navigationRow: some View {
// Navigation buttons
        HStack(spacing: 20) {
            Button {
                Task {
                    drawing = PKDrawing()
                    await viewModel.previousGlyph()
                    showNavigationTip = false
                }
            } label: {
                Label("Previous", systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.hasPrevious)
            .practiceTooltip("Go back to review the previous character")
            
            Spacer()
            
            // Show completion message if at the end
            if !viewModel.hasNext && viewModel.score != nil {
                Button {
                    dismiss()
                } label: {
                    Label("Complete!", systemImage: "checkmark.circle.fill")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .practiceTooltip("You've finished this set!")
            } else {
                Button {
                    Task {
                        drawing = PKDrawing()
                        await viewModel.nextGlyph()
                        showNavigationTip = false
                        // Show evaluation tip for new character
                        if !showEvaluationTip {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    showEvaluationTip = true
                                }
                            }
                        }
                    }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.hasNext)
                .practiceTooltip("Move to the next character")
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

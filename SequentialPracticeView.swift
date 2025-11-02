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
    @State private var showFirstTimeHelp = true
    @State private var showEvaluationTip = false
    @State private var showNavigationTip = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
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
                
                // Contextual tip for evaluation
                SequentialPracticeHelp.InlineTip(
                    icon: "hand.draw",
                    message: "Draw the character, then tap Evaluate to see your score",
                    isVisible: $showEvaluationTip
                )
                
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
                    Text(glyph.literal)
                        .font(.system(size: adaptiveCharacterFontSize))
                        .padding(.top, 20)
                    Text(glyph.meaning.joined(separator: ", "))
                        .foregroundStyle(.secondary)
                    
                    // Show readings if available
                    if !glyph.readings.isEmpty {
                        Text(glyph.readings.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Use GeometryReader to calculate available space for canvas
                    let availableHeight = geometry.size.height - 380 // Reserve space for text, buttons, score, navigation
                    let maxCanvasSize = min(geometry.size.width - 40, availableHeight) // 40 for horizontal padding
                    let canvasSize = min(adaptiveCanvasSize, maxCanvasSize)
                    
                    CanvasRepresentable(drawing: $drawing)
                        .frame(width: canvasSize, height: canvasSize)
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

                    if let score = viewModel.score {
                        VStack(spacing: 4) {
                            Text("Score: \(Int(score.total * 100))%")
                                .font(.headline)
                                .foregroundStyle(score.total > 0.8 ? .green : .orange)
                            
                            if score.total > 0.8 {
                                Text("Great job! 🎉")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Try paying attention to stroke order")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Navigation tip
                    SequentialPracticeHelp.InlineTip(
                        icon: "arrow.left.arrow.right",
                        message: "Use Next to continue, or Previous to review earlier characters",
                        color: .green,
                        isVisible: $showNavigationTip
                    )
                    
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
                    
                    Spacer(minLength: 0)
                }
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

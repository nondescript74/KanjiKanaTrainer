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

                    // Use GeometryReader to calculate available space for canvas
                    let availableHeight = geometry.size.height - 350 // Reserve space for text, buttons, score, navigation
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
                        Spacer()
                        Button("Evaluate") {
                            viewModel.evaluate(drawing)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)

                    if let score = viewModel.score {
                        Text("Score: \(Int(score.total * 100))%")
                            .font(.headline)
                            .foregroundStyle(score.total > 0.8 ? .green : .orange)
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        Button {
                            Task {
                                drawing = PKDrawing()
                                await viewModel.previousGlyph()
                            }
                        } label: {
                            Label("Previous", systemImage: "chevron.left")
                        }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.hasPrevious)
                        
                        Spacer()
                        
                        Button {
                            Task {
                                drawing = PKDrawing()
                                await viewModel.nextGlyph()
                            }
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                                .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.hasNext)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .navigationTitle("Sequential Practice")
        .task {
            await viewModel.loadCurrentGlyph()
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

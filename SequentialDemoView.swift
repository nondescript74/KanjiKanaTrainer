//
//  SequentialDemoView.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// A view that demonstrates characters sequentially with stroke-by-stroke animation
struct SequentialDemoView: View {
    @StateObject var viewModel: SequentialDemoViewModel
    @State private var showHelp = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            progressBar
            
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        ProgressView("Loading character...")
                            .padding()
                    } else if let glyph = viewModel.currentGlyph {
                        // Character display
                        characterHeader(glyph: glyph)
                        
                        // Demo canvas
                        demoCanvas(glyph: glyph)
                        
                        // Controls
                        controlButtons
                        
                        // Navigation
                        navigationButtons
                        
                    } else if let error = viewModel.error {
                        errorView(error: error)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Sequential Demo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            SequentialDemoHelp()
        }
        .task {
            await viewModel.loadCurrentGlyph()
        }
    }
    
    // MARK: - View Components
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text(viewModel.progressString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if viewModel.autoPlayEnabled {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                        Text("Auto-play")
                            .font(.caption2)
                    }
                    .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * viewModel.sequenceProgress)
                }
            }
            .frame(height: 4)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Color(UIColor.systemBackground))
    }
    
    private func characterHeader(glyph: CharacterGlyph) -> some View {
        VStack(spacing: 8) {
            Text(glyph.literal)
                .font(.system(size: adaptiveCharacterFontSize))
                .fontWeight(.light)
            
            Text(glyph.meaning.joined(separator: ", "))
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func demoCanvas(glyph: CharacterGlyph) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .frame(width: adaptiveCanvasSize, height: adaptiveCanvasSize)
                
                if viewModel.demoState != .idle {
                    Canvas { context, size in
                        // Calculate bounding box from all strokes
                        let allGlyphPoints = glyph.strokes.flatMap { stroke in
                            stroke.points.map { point in
                                CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
                            }
                        }
                        
                        guard !allGlyphPoints.isEmpty else { return }
                        
                        let minX = allGlyphPoints.map { $0.x }.min() ?? 0
                        let maxX = allGlyphPoints.map { $0.x }.max() ?? 1
                        let minY = allGlyphPoints.map { $0.y }.min() ?? 0
                        let maxY = allGlyphPoints.map { $0.y }.max() ?? 1
                        
                        let strokeWidth = maxX - minX
                        let strokeHeight = maxY - minY
                        
                        let padding: CGFloat = 30
                        let availableSize = CGSize(
                            width: size.width - (padding * 2),
                            height: size.height - (padding * 2)
                        )
                        
                        let scaleX = strokeWidth > 0 ? availableSize.width / strokeWidth : availableSize.width
                        let scaleY = strokeHeight > 0 ? availableSize.height / strokeHeight : availableSize.height
                        let scale = min(scaleX, scaleY)
                        
                        let boundingBoxCenterX = (minX + maxX) / 2
                        let boundingBoxCenterY = (minY + maxY) / 2
                        let canvasCenterX = size.width / 2
                        let canvasCenterY = size.height / 2
                        let offsetX = canvasCenterX - (boundingBoxCenterX * scale)
                        let offsetY = canvasCenterY - (boundingBoxCenterY * scale)
                        
                        // Draw completed strokes
                        for stroke in viewModel.drawnStrokes {
                            if stroke.count > 1 {
                                var path = Path()
                                let scaledStart = CGPoint(
                                    x: offsetX + (stroke[0].x * scale),
                                    y: offsetY + (stroke[0].y * scale)
                                )
                                path.move(to: scaledStart)
                                
                                for point in stroke.dropFirst() {
                                    let scaledPoint = CGPoint(
                                        x: offsetX + (point.x * scale),
                                        y: offsetY + (point.y * scale)
                                    )
                                    path.addLine(to: scaledPoint)
                                }
                                
                                context.stroke(
                                    path,
                                    with: .color(.blue),
                                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                                )
                            }
                        }
                        
                        // Draw current stroke being animated
                        if viewModel.currentStroke.count > 1 {
                            var path = Path()
                            let scaledStart = CGPoint(
                                x: offsetX + (viewModel.currentStroke[0].x * scale),
                                y: offsetY + (viewModel.currentStroke[0].y * scale)
                            )
                            path.move(to: scaledStart)
                            
                            for point in viewModel.currentStroke.dropFirst() {
                                let scaledPoint = CGPoint(
                                    x: offsetX + (point.x * scale),
                                    y: offsetY + (point.y * scale)
                                )
                                path.addLine(to: scaledPoint)
                            }
                            
                            context.stroke(
                                path,
                                with: .color(.teal),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                            )
                        }
                    }
                    .frame(width: adaptiveCanvasSize, height: adaptiveCanvasSize)
                }
                
                // Demo state overlay removed - use Play Demo button instead
            }
            
            // Stroke progress
            if viewModel.demoState == .drawing {
                HStack {
                    Text("Drawing...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            } else if viewModel.demoState == .completed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Complete!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 12) {
            // Play/Replay button
            Button {
                if viewModel.demoState == .idle || viewModel.demoState == .completed {
                    viewModel.startDemo()
                }
            } label: {
                HStack {
                    Image(systemName: viewModel.demoState == .completed ? "arrow.clockwise" : "play.fill")
                    Text(viewModel.demoState == .completed ? "Replay" : "Play Demo")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.demoState == .drawing)
            
            // Stop button
            if viewModel.demoState == .drawing {
                Button {
                    viewModel.stopDemo()
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
            }
            
            // Auto-play toggle
            Button {
                viewModel.autoPlayEnabled.toggle()
            } label: {
                Image(systemName: viewModel.autoPlayEnabled ? "repeat.circle.fill" : "repeat.circle")
                    .font(.title2)
                    .foregroundStyle(viewModel.autoPlayEnabled ? .blue : .gray)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Previous button
            Button {
                viewModel.previousGlyph()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.hasPrevious ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.1))
                )
                .foregroundStyle(viewModel.hasPrevious ? .primary : .secondary)
            }
            .disabled(!viewModel.hasPrevious)
            
            // Next button
            Button {
                viewModel.nextGlyph()
            } label: {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.hasNext ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.1))
                )
                .foregroundStyle(viewModel.hasNext ? .primary : .secondary)
            }
            .disabled(!viewModel.hasNext)
        }
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            
            Text("Unable to Load Character")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadCurrentGlyph()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SequentialDemoView(
            viewModel: .hiraganaVowels(
                env: AppEnvironment(
                    glyphs: GlyphBundleRepository(),
                    progress: SwiftDataProgressStore(),
                    evaluator: DefaultAttemptEvaluator()
                )
            )
        )
    }
}

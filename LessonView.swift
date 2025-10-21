import SwiftUI

struct LessonView: View {
    @StateObject var viewModel: LessonViewModel

    // Drawing configuration
    var brushColor: Color = .blue
    var activeBrushColor: Color = .teal
    var brushLineWidth: CGFloat = 6

    var body: some View {
        VStack(spacing: 16) {
            if let glyph = viewModel.glyph {
                // Header
                Text(glyph.literal).font(.system(size: 80))
                Text(glyph.meaning.joined(separator: ", "))
                    .font(.title3).foregroundStyle(.secondary)

                // Demo area
                if viewModel.demoState != .idle {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .frame(width: 300, height: 300)
                            .overlay(
                                Canvas { context, size in
                                    // Draw completed strokes
                                    let strokes = viewModel.drawnStrokes
                                    for stroke in strokes {
                                        guard stroke.count > 1 else { continue }
                                        var path = Path()
                                        // Scale normalized coordinates (0-1) to canvas size
                                        let scaledPoints = stroke.map { point in
                                            CGPoint(x: point.x * size.width, y: point.y * size.height)
                                        }
                                        path.addLines(scaledPoints)
                                        // Calligraphy-like layered stroke for completed strokes
                                        // Base body
                                        context.stroke(
                                            path,
                                            with: .color(brushColor.opacity(0.95)),
                                            style: StrokeStyle(lineWidth: brushLineWidth, lineCap: .round, lineJoin: .round)
                                        )
                                        // Soft edge (slightly wider and more transparent)
                                        context.addFilter(.blur(radius: 0.6))
                                        context.stroke(
                                            path,
                                            with: .color(brushColor.opacity(0.25)),
                                            style: StrokeStyle(lineWidth: brushLineWidth * 1.4, lineCap: .round, lineJoin: .round)
                                        )
                                        context.addFilter(.blur(radius: 0))
                                        // Inner sheen to mimic ink variation
                                        context.stroke(
                                            path,
                                            with: .color(brushColor.opacity(0.35)),
                                            style: StrokeStyle(lineWidth: brushLineWidth * 0.55, lineCap: .round, lineJoin: .round)
                                        )
                                    }
                                    // Draw current stroke in progress
                                    let current = viewModel.currentStroke
                                    if current.count > 1 {
                                        var path = Path()
                                        // Scale normalized coordinates (0-1) to canvas size
                                        let scaledPoints = current.map { point in
                                            CGPoint(x: point.x * size.width, y: point.y * size.height)
                                        }
                                        path.addLines(scaledPoints)
                                        // Calligraphy-like layered stroke for in-progress stroke
                                        context.stroke(
                                            path,
                                            with: .color(activeBrushColor.opacity(0.95)),
                                            style: StrokeStyle(lineWidth: brushLineWidth, lineCap: .round, lineJoin: .round)
                                        )
                                        context.addFilter(.blur(radius: 0.6))
                                        context.stroke(
                                            path,
                                            with: .color(activeBrushColor.opacity(0.22)),
                                            style: StrokeStyle(lineWidth: brushLineWidth * 1.4, lineCap: .round, lineJoin: .round)
                                        )
                                        context.addFilter(.blur(radius: 0))
                                        context.stroke(
                                            path,
                                            with: .color(activeBrushColor.opacity(0.35)),
                                            style: StrokeStyle(lineWidth: brushLineWidth * 0.55, lineCap: .round, lineJoin: .round)
                                        )
                                    }
                                }
                                .allowsHitTesting(false)
                                .padding(8)
                            )

                        VStack(spacing: 12) {
                            Text(statusText(viewModel.demoState))
                                .font(.headline)
                            ProgressView(value: viewModel.progress)
                                .progressViewStyle(.linear)
                                .frame(maxWidth: 200)
                            if let glyph = viewModel.glyph {
                                Text("Strokes: \(viewModel.drawnStrokes.count)/\(glyph.strokes.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                    }

                    HStack(spacing: 12) {
                        if viewModel.demoState == .completed {
                            Button("Replay") { viewModel.startDemo() }
                                .buttonStyle(.borderedProminent)
                        }
                        Button("Stop", role: .destructive) { viewModel.stopDemo() }
                            .buttonStyle(.bordered)
                    }
                } else {
                    Spacer(minLength: 24)
                    
                    VStack(spacing: 12) {
                        Button("Start Demo") { viewModel.startDemo() }
                            .buttonStyle(.borderedProminent)
                            .disabled(glyph.strokes.isEmpty)
                        
                        if glyph.strokes.isEmpty {
                            Text("No stroke data available for this character")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(glyph.strokes.count) stroke\(glyph.strokes.count == 1 ? "" : "s") loaded")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                ProgressView("Loading…")
            }
        }
        .padding()
        .task { await viewModel.loadGlyph() }
        .navigationTitle("Lesson Demo")
    }
}

private func statusText(_ state: LessonViewModel.DemoState) -> String {
    switch state {
    case .idle: return ""
    case .drawing: return "Watch how the character is drawn..."
    case .completed: return "Demo Complete!"
    }
}

import SwiftUI

struct LessonView: View {
    @StateObject var viewModel: LessonViewModel

    // Drawing configuration
    var brushColor: Color = .blue
    var activeBrushColor: Color = .teal
    var brushLineWidth: CGFloat = 6
    var showDebugBounds: Bool = false  // Set to true to visualize bounding box

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
                                    // Calculate bounding box from ALL strokes in the glyph (not just drawn ones)
                                    // This ensures consistent positioning throughout the animation
                                    guard let glyph = viewModel.glyph, !glyph.strokes.isEmpty else { return }
                                    
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
                                    
                                    // Add padding to prevent strokes from touching edges
                                    let padding: CGFloat = 30
                                    let availableSize = CGSize(
                                        width: size.width - (padding * 2),
                                        height: size.height - (padding * 2)
                                    )
                                    
                                    // Calculate scale to fit strokes within available space while maintaining aspect ratio
                                    let scaleX = strokeWidth > 0 ? availableSize.width / strokeWidth : availableSize.width
                                    let scaleY = strokeHeight > 0 ? availableSize.height / strokeHeight : availableSize.height
                                    let scale = min(scaleX, scaleY)
                                    
                                    // Calculate offset to center the strokes properly
                                    // Center based on the bounding box center, not just edges
                                    let boundingBoxCenterX = (minX + maxX) / 2
                                    let boundingBoxCenterY = (minY + maxY) / 2
                                    let canvasCenterX = size.width / 2
                                    let canvasCenterY = size.height / 2
                                    let offsetX = canvasCenterX - (boundingBoxCenterX * scale)
                                    let offsetY = canvasCenterY - (boundingBoxCenterY * scale)
                                    
                                    // Debug visualization (if enabled)
                                    if showDebugBounds {
                                        let debugRect = CGRect(
                                            x: offsetX + (minX * scale),
                                            y: offsetY + (minY * scale),
                                            width: strokeWidth * scale,
                                            height: strokeHeight * scale
                                        )
                                        context.stroke(
                                            Path(debugRect),
                                            with: .color(.red.opacity(0.5)),
                                            style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                                        )
                                        // Draw center point
                                        let center = CGPoint(x: canvasCenterX, y: canvasCenterY)
                                        context.fill(
                                            Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)),
                                            with: .color(.red)
                                        )
                                    }
                                    
                                    // Draw completed strokes
                                    let strokes = viewModel.drawnStrokes
                                    for stroke in strokes {
                                        guard stroke.count > 1 else { continue }
                                        var path = Path()
                                        // Scale and position coordinates
                                        let scaledPoints = stroke.map { point in
                                            CGPoint(
                                                x: offsetX + (point.x * scale),
                                                y: offsetY + (point.y * scale)
                                            )
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
                                        // Scale and position coordinates
                                        let scaledPoints = current.map { point in
                                            CGPoint(
                                                x: offsetX + (point.x * scale),
                                                y: offsetY + (point.y * scale)
                                            )
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
                        
                        #if DEBUG
                        Button("Debug Data") {
                            debugStrokeData(for: glyph)
                        }
                        .buttonStyle(.bordered)
                        #endif
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

#if DEBUG
extension LessonView {
    /// Print stroke data for debugging positioning issues
    func debugStrokeData(for glyph: CharacterGlyph) {
        print("\n=== Stroke Data Debug for '\(glyph.literal)' (U+\(String(format: "%04X", glyph.codepoint))) ===")
        for (index, stroke) in glyph.strokes.enumerated() {
            let points = stroke.points
            let xValues = points.map { CGFloat($0.x) }
            let yValues = points.map { CGFloat($0.y) }
            let minX = xValues.min() ?? 0
            let maxX = xValues.max() ?? 0
            let minY = yValues.min() ?? 0
            let maxY = yValues.max() ?? 0
            
            print("Stroke \(index + 1): \(points.count) points")
            print("  X range: \(String(format: "%.3f", minX)) - \(String(format: "%.3f", maxX))")
            print("  Y range: \(String(format: "%.3f", minY)) - \(String(format: "%.3f", maxY))")
            print("  First point: (\(String(format: "%.3f", points.first?.x ?? 0)), \(String(format: "%.3f", points.first?.y ?? 0)))")
            print("  Last point: (\(String(format: "%.3f", points.last?.x ?? 0)), \(String(format: "%.3f", points.last?.y ?? 0)))")
        }
        print("===========================================\n")
    }
}
#endif

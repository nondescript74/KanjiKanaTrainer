import Foundation
import Combine
import CoreGraphics

@MainActor
final class LessonViewModel: ObservableObject {
    enum DemoState: Equatable {
        case idle
        case drawing
        case completed
    }

    @Published var glyph: CharacterGlyph?
    @Published var demoState: DemoState = .idle
    @Published var drawnStrokes: [[CGPoint]] = []
    @Published var currentStroke: [CGPoint] = []
    @Published var progress: Double = 0.0

    private let env: AppEnvironment
    private let glyphID: CharacterID
    private var animationTask: Task<Void, Never>?

    init(id: CharacterID, env: AppEnvironment) {
        self.glyphID = id
        self.env = env
    }
    
    deinit {
        animationTask?.cancel()
    }

    func loadGlyph() async {
        do {
            glyph = try await env.glyphs.glyph(for: glyphID)
        } catch {
            print("Failed to load glyph: \(error)")
        }
    }

    // MARK: - Demo Animation API

    func startDemo() {
        guard let g = glyph else {
            print("⚠️ Cannot start demo: Glyph not loaded")
            return
        }
        
        guard !g.strokes.isEmpty else {
            print("⚠️ No stroke data available for demo")
            print("   Character: '\(g.literal)' (U+\(String(format: "%04X", g.codepoint)))")
            print("   Script: \(g.script)")
            print("   This usually means kanastrokes.json is missing or doesn't contain this character")
            print("   Check the Debug view (StrokeDataDebugView) for more information")
            return
        }
        
        // Cancel any existing animation
        animationTask?.cancel()
        
        // Reset state
        demoState = .drawing
        drawnStrokes = []
        currentStroke = []
        progress = 0.0
        
        print("▶️ Starting demo for '\(g.literal)' with \(g.strokes.count) strokes")
        
        // Start animated drawing
        animationTask = Task {
            await animateDrawing(strokes: g.strokes)
        }
    }
    
    func stopDemo() {
        animationTask?.cancel()
        demoState = .idle
        drawnStrokes = []
        currentStroke = []
        progress = 0.0
    }
    
    private func animateDrawing(strokes: [StrokePath]) async {
        // Store normalized points (0-1 range) and let the Canvas scale them
        for (strokeIndex, strokePath) in strokes.enumerated() {
            guard !Task.isCancelled else { return }
            
            let points = strokePath.points.map { point in
                // Store as normalized coordinates (0.0 to 1.0)
                CGPoint(
                    x: CGFloat(point.x),
                    y: CGFloat(point.y)
                )
            }
            
            guard !points.isEmpty else { continue }
            
            // Animate drawing this stroke point by point
            currentStroke = []
            
            for point in points {
                guard !Task.isCancelled else { return }
                
                currentStroke.append(point)
                
                // Small delay between points for smooth animation
                try? await Task.sleep(nanoseconds: 15_000_000) // 15ms
            }
            
            // Stroke complete - move to drawn strokes
            drawnStrokes.append(currentStroke)
            currentStroke = []
            
            // Update progress
            progress = Double(strokeIndex + 1) / Double(strokes.count)
            
            // Pause between strokes
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        }
        
        // All strokes complete
        demoState = .completed
    }
    
    // Convert StrokePath to CGPoint array
    private func convertStrokePoints(_ stroke: StrokePath, width: CGFloat, height: CGFloat) -> [CGPoint] {
        return stroke.points.map { point in
            CGPoint(
                x: CGFloat(point.x) * width,
                y: CGFloat(point.y) * height
            )
        }
    }
}

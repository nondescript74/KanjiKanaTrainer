import SwiftUI
import PencilKit

/// PencilKit canvas that accepts Apple Pencil or a finger.
struct WritingCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeCoordinator() -> Coordinator { Coordinator(drawing: $drawing) }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.tool = PKInkingTool(.pen, color: .label, width: 14)
        canvas.isScrollEnabled = false
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.accessibilityLabel = "Writing area"
        canvas.accessibilityHint = "Write the character with your finger or Apple Pencil."
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            context.coordinator.isUpdating = true
            uiView.drawing = drawing
            context.coordinator.isUpdating = false
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var isUpdating = false
        init(drawing: Binding<PKDrawing>) { _drawing = drawing }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !isUpdating else { return }
            let d = canvasView.drawing
            DispatchQueue.main.async { self.drawing = d }
        }
    }
}

extension PKDrawing {
    /// The user's strokes as evaluator input, in canvas points (y down).
    var strokePaths: [StrokePath] {
        strokes.map { stroke in
            let pts = stroke.path.interpolatedPoints(by: .distance(4)).map { p -> StrokePoint in
                let loc = p.location.applying(stroke.transform)
                return StrokePoint(x: Double(loc.x), y: Double(loc.y))
            }
            return StrokePath(points: pts)
        }
    }

    /// Builds a drawing from unit-box strokes, used by "Show a common mistake".
    static func from(_ strokes: [StrokePath], in size: CGSize) -> PKDrawing {
        let ink = PKInk(.pen, color: .label)
        let pk = strokes.map { path -> PKStroke in
            let pts = path.points.enumerated().map { i, p in
                PKStrokePoint(location: CGPoint(x: p.x * size.width, y: p.y * size.height),
                              timeOffset: TimeInterval(i) * 0.02,
                              size: CGSize(width: 14, height: 14),
                              opacity: 1, force: 1, azimuth: 0, altitude: .pi / 2)
            }
            return PKStroke(ink: ink, path: PKStrokePath(controlPoints: pts, creationDate: Date()))
        }
        return PKDrawing(strokes: pk)
    }
}

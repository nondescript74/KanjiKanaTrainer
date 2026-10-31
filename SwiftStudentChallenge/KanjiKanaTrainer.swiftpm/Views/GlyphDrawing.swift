import SwiftUI

/// A stroke polyline in a unit box, drawn into whatever rect it is given.
struct StrokeShape: Shape {
    let points: [StrokeGeometry.Point]
    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard let f = points.first else { return p }
        p.move(to: CGPoint(x: rect.minX + f.x * rect.width, y: rect.minY + f.y * rect.height))
        for q in points.dropFirst() {
            p.addLine(to: CGPoint(x: rect.minX + q.x * rect.width, y: rect.minY + q.y * rect.height))
        }
        return p
    }
}

extension StrokePath {
    var unitPoints: [StrokeGeometry.Point] { points.map { (x: $0.x, y: $0.y) } }
}

/// The 田字格 / 米字格 practice square children use in class.
struct PracticeGrid: View {
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            ZStack {
                RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.55), lineWidth: 2)
                Path { p in
                    p.move(to: CGPoint(x: w / 2, y: 0)); p.addLine(to: CGPoint(x: w / 2, y: h))
                    p.move(to: CGPoint(x: 0, y: h / 2)); p.addLine(to: CGPoint(x: w, y: h / 2))
                    p.move(to: .zero); p.addLine(to: CGPoint(x: w, y: h))
                    p.move(to: CGPoint(x: w, y: 0)); p.addLine(to: CGPoint(x: 0, y: h))
                }
                .stroke(Color.red.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
            }
        }
        .accessibilityHidden(true)
    }
}

/// Numbered start dot with a small arrow showing which way the stroke goes.
struct StrokeStartMarker: View {
    let number: Int
    let stroke: [StrokeGeometry.Point]
    let size: CGSize
    var color: Color = .accentColor

    var body: some View {
        if let a = stroke.first {
            let b = stroke.count > 3 ? stroke[3] : (stroke.last ?? a)
            let angle = atan2(b.y - a.y, b.x - a.x)
            ZStack {
                Circle().fill(color).frame(width: 26, height: 26)
                Text("\(number)").font(.caption.bold()).foregroundStyle(.white)
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 15)).foregroundStyle(color)
                    .offset(x: 23).rotationEffect(.radians(angle))
            }
            .position(x: a.x * size.width, y: a.y * size.height)
            .accessibilityHidden(true)
        }
    }
}

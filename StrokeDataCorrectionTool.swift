import SwiftUI

#if DEBUG
/// Tool for identifying and correcting problematic stroke data
struct StrokeDataCorrectionTool: View {
    @State private var selectedCharacter: String = "ぴ"
    @State private var strokeData: [StrokePath]?
    @State private var issuesFound: [StrokeIssue] = []
    
    // Common problematic characters
    let problematicCharacters = [
        "ぴ", "び", "ぎ", "ざ", "だ", "ば", "ぱ",  // Hiragana with diacriticals
        "み", "ぬ", "ね", "ゆ", "よ",  // Multi-stroke hiragana
        "ピ", "ビ", "ギ", "ザ", "ダ", "バ", "パ"   // Katakana with diacriticals
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section("Select Character") {
                    Picker("Character", selection: $selectedCharacter) {
                        ForEach(problematicCharacters, id: \.self) { char in
                            Text(char).tag(char)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedCharacter) { _, _ in
                        loadAndAnalyze()
                    }
                }
                
                Section("Stroke Analysis") {
                    if let strokes = strokeData {
                        ForEach(Array(strokes.enumerated()), id: \.offset) { index, stroke in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stroke \(index + 1)")
                                    .font(.headline)
                                
                                let analysis = analyzeStroke(stroke, index: index)
                                
                                HStack {
                                    Text("Points:")
                                    Text("\(stroke.points.count)")
                                        .foregroundStyle(analysis.pointCountIssue ? .red : .secondary)
                                }
                                .font(.caption)
                                
                                HStack {
                                    Text("X range:")
                                    Text("\(String(format: "%.3f", analysis.minX)) - \(String(format: "%.3f", analysis.maxX))")
                                        .foregroundStyle(analysis.xRangeIssue ? .red : .secondary)
                                }
                                .font(.caption)
                                
                                HStack {
                                    Text("Y range:")
                                    Text("\(String(format: "%.3f", analysis.minY)) - \(String(format: "%.3f", analysis.maxY))")
                                        .foregroundStyle(analysis.yRangeIssue ? .red : .secondary)
                                }
                                .font(.caption)
                                
                                if analysis.hasIssue {
                                    Text("⚠️ Issues detected")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } else {
                        Text("No stroke data loaded")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Issues Found") {
                    if issuesFound.isEmpty {
                        Text("No issues detected")
                            .foregroundStyle(.green)
                    } else {
                        ForEach(issuesFound) { issue in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(issue.title)
                                    .font(.headline)
                                Text(issue.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                
                Section("Visual Preview") {
                    if let strokes = strokeData {
                        Canvas { context, size in
                            for (index, stroke) in strokes.enumerated() {
                                guard !stroke.points.isEmpty else { continue }
                                var path = Path()
                                let points = stroke.points.map { point in
                                    CGPoint(
                                        x: CGFloat(point.x) * size.width,
                                        y: CGFloat(point.y) * size.height
                                    )
                                }
                                
                                if points.count > 1 {
                                    path.addLines(points)
                                    // Use different colors for each stroke
                                    let colors: [Color] = [.blue, .red, .green, .orange, .purple]
                                    let color = colors[index % colors.count]
                                    context.stroke(
                                        path,
                                        with: .color(color),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                                    )
                                }
                            }
                            
                            // Draw grid for reference
                            let gridColor = Color.gray.opacity(0.2)
                            for i in 0...4 {
                                let x = CGFloat(i) * size.width / 4
                                let y = CGFloat(i) * size.height / 4
                                
                                // Vertical lines
                                var vLine = Path()
                                vLine.move(to: CGPoint(x: x, y: 0))
                                vLine.addLine(to: CGPoint(x: x, y: size.height))
                                context.stroke(vLine, with: .color(gridColor), lineWidth: 1)
                                
                                // Horizontal lines
                                var hLine = Path()
                                hLine.move(to: CGPoint(x: 0, y: y))
                                hLine.addLine(to: CGPoint(x: size.width, y: y))
                                context.stroke(hLine, with: .color(gridColor), lineWidth: 1)
                            }
                        }
                        .frame(height: 300)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                
                Section("Actions") {
                    Button("Reload Data") {
                        loadAndAnalyze()
                    }
                    
                    Button("Export Issues Report") {
                        exportIssuesReport()
                    }
                }
            }
            .navigationTitle("Stroke Data Correction")
            .onAppear {
                loadAndAnalyze()
            }
        }
    }
    
    // MARK: - Analysis
    
    struct StrokeAnalysis {
        let minX: CGFloat
        let maxX: CGFloat
        let minY: CGFloat
        let maxY: CGFloat
        let pointCount: Int
        
        var xRangeIssue: Bool {
            // Flag if stroke spans the entire width (0.0 to 1.0)
            return abs(minX - 0.0) < 0.01 && abs(maxX - 1.0) < 0.01
        }
        
        var yRangeIssue: Bool {
            // Flag if stroke spans the entire height (0.0 to 1.0)
            return abs(minY - 0.0) < 0.01 && abs(maxY - 1.0) < 0.01
        }
        
        var pointCountIssue: Bool {
            // Flag if too few points or duplicate points
            return pointCount < 3
        }
        
        var hasIssue: Bool {
            return xRangeIssue || yRangeIssue || pointCountIssue
        }
    }
    
    func analyzeStroke(_ stroke: StrokePath, index: Int) -> StrokeAnalysis {
        let points = stroke.points
        let xValues = points.map { CGFloat($0.x) }
        let yValues = points.map { CGFloat($0.y) }
        
        return StrokeAnalysis(
            minX: xValues.min() ?? 0,
            maxX: xValues.max() ?? 0,
            minY: yValues.min() ?? 0,
            maxY: yValues.max() ?? 0,
            pointCount: points.count
        )
    }
    
    func loadAndAnalyze() {
        // Load stroke data
        strokeData = KanaStrokeDataLoader.shared.loadStrokes(for: selectedCharacter)
        
        // Analyze for issues
        issuesFound = []
        
        guard let strokes = strokeData else {
            issuesFound.append(StrokeIssue(
                title: "No Data Found",
                description: "Stroke data not found for character '\(selectedCharacter)'"
            ))
            return
        }
        
        for (index, stroke) in strokes.enumerated() {
            let analysis = analyzeStroke(stroke, index: index)
            
            if analysis.xRangeIssue {
                issuesFound.append(StrokeIssue(
                    title: "Stroke \(index + 1): Full Width Span",
                    description: "Stroke spans entire width (0.0 - 1.0), likely incorrect"
                ))
            }
            
            if analysis.yRangeIssue {
                issuesFound.append(StrokeIssue(
                    title: "Stroke \(index + 1): Full Height Span",
                    description: "Stroke spans entire height (0.0 - 1.0), likely incorrect"
                ))
            }
            
            if analysis.pointCountIssue {
                issuesFound.append(StrokeIssue(
                    title: "Stroke \(index + 1): Too Few Points",
                    description: "Only \(analysis.pointCount) points, may indicate data corruption"
                ))
            }
            
            // Check for duplicate points
            if stroke.points.count > 1 {
                let first = stroke.points.first!
                let last = stroke.points.last!
                if abs(first.x - last.x) < 0.001 && abs(first.y - last.y) < 0.001 {
                    issuesFound.append(StrokeIssue(
                        title: "Stroke \(index + 1): Duplicate Points",
                        description: "First and last points are identical"
                    ))
                }
            }
        }
    }
    
    func exportIssuesReport() {
        print("\n=== Stroke Data Issues Report ===")
        print("Character: '\(selectedCharacter)'")
        print("Issues found: \(issuesFound.count)")
        print("")
        
        for issue in issuesFound {
            print("• \(issue.title)")
            print("  \(issue.description)")
            print("")
        }
        
        if let strokes = strokeData {
            print("Detailed Stroke Data:")
            for (index, stroke) in strokes.enumerated() {
                print("\nStroke \(index + 1):")
                print("  Points: \(stroke.points.count)")
                let analysis = analyzeStroke(stroke, index: index)
                print("  X range: \(String(format: "%.3f", analysis.minX)) - \(String(format: "%.3f", analysis.maxX))")
                print("  Y range: \(String(format: "%.3f", analysis.minY)) - \(String(format: "%.3f", analysis.maxY))")
            }
        }
        
        print("\n================================\n")
    }
}

struct StrokeIssue: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

#Preview {
    StrokeDataCorrectionTool()
}
#endif

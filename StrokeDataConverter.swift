import Foundation

/// Utility for validating and debugging combined stroke data JSON files
/// This is useful for:
/// - Validating combined JSON files (kanastrokes.json)
/// - Debugging stroke data issues
/// - Generating statistics
struct StrokeDataConverter {
    
    // MARK: - Validation
    
    /// Validate the combined kanastrokes.json file
    /// - Returns: Validation result with statistics
    static func validateCombinedJSON() -> ValidationSummary {
        let loader = KanaStrokeDataLoader.shared
        let codepoints = loader.availableCodepoints
        
        var summary = ValidationSummary()
        summary.totalCharacters = codepoints.count
        
        for codepoint in codepoints {
            guard let strokes = loader.loadStrokes(for: codepoint) else {
                summary.failedCharacters.append(codepoint)
                continue
            }
            
            // Validate stroke structure
            if strokes.isEmpty {
                summary.emptyStrokes.append(codepoint)
                continue
            }
            
            // Validate each stroke
            for (strokeIndex, stroke) in strokes.enumerated() {
                if stroke.points.isEmpty {
                    summary.emptyPoints.append((codepoint, strokeIndex))
                    continue
                }
                
                // Validate point coordinates are normalized
                for point in stroke.points {
                    if point.x < 0 || point.x > 1 || point.y < 0 || point.y > 1 {
                        summary.invalidCoordinates.append((codepoint, strokeIndex))
                        break
                    }
                }
            }
            
            summary.validCharacters += 1
        }
        
        return summary
    }
    
    /// Print a detailed validation report
    static func printValidationReport() {
        print("\n=== Kana Stroke Data Validation Report ===\n")
        
        let summary = validateCombinedJSON()
        
        print("📊 Statistics:")
        print("   Total characters: \(summary.totalCharacters)")
        print("   Valid characters: \(summary.validCharacters)")
        print("   Failed to load: \(summary.failedCharacters.count)")
        print("   Empty strokes: \(summary.emptyStrokes.count)")
        print("   Empty points: \(summary.emptyPoints.count)")
        print("   Invalid coordinates: \(summary.invalidCoordinates.count)")
        
        if summary.isValid {
            print("\n✅ All stroke data is valid!")
        } else {
            print("\n⚠️ Issues found:")
            
            if !summary.failedCharacters.isEmpty {
                print("\n   Failed to load:")
                for codepoint in summary.failedCharacters.prefix(10) {
                    let hex = String(format: "U+%04X", codepoint)
                    print("      - \(hex)")
                }
                if summary.failedCharacters.count > 10 {
                    print("      ... and \(summary.failedCharacters.count - 10) more")
                }
            }
            
            if !summary.emptyStrokes.isEmpty {
                print("\n   Empty strokes:")
                for codepoint in summary.emptyStrokes.prefix(10) {
                    let hex = String(format: "U+%04X", codepoint)
                    print("      - \(hex)")
                }
            }
            
            if !summary.invalidCoordinates.isEmpty {
                print("\n   Invalid coordinates:")
                for (codepoint, stroke) in summary.invalidCoordinates.prefix(10) {
                    let hex = String(format: "U+%04X", codepoint)
                    print("      - \(hex) stroke \(stroke)")
                }
            }
        }
        
        print("\n==========================================\n")
    }
    
    // MARK: - Statistics
    
    /// Get statistics about the stroke data
    static func getStatistics() -> StrokeStatistics {
        let loader = KanaStrokeDataLoader.shared
        let codepoints = loader.availableCodepoints
        
        var stats = StrokeStatistics()
        stats.characterCount = codepoints.count
        
        for codepoint in codepoints {
            guard let strokes = loader.loadStrokes(for: codepoint) else { continue }
            
            let strokeCount = strokes.count
            stats.totalStrokes += strokeCount
            stats.minStrokes = min(stats.minStrokes ?? strokeCount, strokeCount)
            stats.maxStrokes = max(stats.maxStrokes ?? strokeCount, strokeCount)
            
            for stroke in strokes {
                stats.totalPoints += stroke.points.count
            }
        }
        
        if stats.characterCount > 0 {
            stats.averageStrokesPerCharacter = Double(stats.totalStrokes) / Double(stats.characterCount)
        }
        
        if stats.totalStrokes > 0 {
            stats.averagePointsPerStroke = Double(stats.totalPoints) / Double(stats.totalStrokes)
        }
        
        return stats
    }
    
    /// Print stroke data statistics
    static func printStatistics() {
        print("\n=== Kana Stroke Data Statistics ===\n")
        
        let stats = getStatistics()
        
        print("Characters: \(stats.characterCount)")
        print("Total strokes: \(stats.totalStrokes)")
        print("Total points: \(stats.totalPoints)")
        
        if let min = stats.minStrokes, let max = stats.maxStrokes {
            print("Strokes per character: \(min) - \(max) (avg: \(String(format: "%.1f", stats.averageStrokesPerCharacter)))")
        }
        
        print("Points per stroke: avg \(String(format: "%.1f", stats.averagePointsPerStroke))")
        
        print("\n===================================\n")
    }
    
    // MARK: - Supporting Types
    
    struct ValidationSummary {
        var totalCharacters = 0
        var validCharacters = 0
        var failedCharacters: [UInt32] = []
        var emptyStrokes: [UInt32] = []
        var emptyPoints: [(codepoint: UInt32, stroke: Int)] = []
        var invalidCoordinates: [(codepoint: UInt32, stroke: Int)] = []
        
        var isValid: Bool {
            return failedCharacters.isEmpty &&
                   emptyStrokes.isEmpty &&
                   emptyPoints.isEmpty &&
                   invalidCoordinates.isEmpty
        }
    }
    
    struct StrokeStatistics {
        var characterCount = 0
        var totalStrokes = 0
        var totalPoints = 0
        var minStrokes: Int?
        var maxStrokes: Int?
        var averageStrokesPerCharacter: Double = 0
        var averagePointsPerStroke: Double = 0
    }
}

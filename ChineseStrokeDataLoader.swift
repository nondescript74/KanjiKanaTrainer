import Foundation

/// Handles loading stroke data for Chinese characters (Hanzi) from JSON files
class ChineseStrokeDataLoader {
    static let shared = ChineseStrokeDataLoader()
    
    // MARK: - JSON Structure
    
    struct JSONStrokePoint: Codable {
        let x: Double
        let y: Double
        let t: Double
    }
    
    struct ChineseCharacterData: Codable {
        let character: String
        let codepoint: Int
        let strokes: [[JSONStrokePoint]]
    }
    
    // MARK: - Cache
    
    private var strokeData: [String: ChineseCharacterData] = [:]
    
    private init() {
        loadStrokeData()
    }
    
    // MARK: - Loading Methods
    
    private func loadStrokeData() {
        #if DEBUG
        print("🔍 Loading Chinese character stroke data...")
        #endif
        
        // Load numbers (0-30 and bonus characters)
        loadDataFile(named: "chinesenumbers", label: "Numbers")
        
        // Load 100 common characters
        loadDataFile(named: "chinese_stroke_data", label: "Common Characters")
    }
    
    private func loadDataFile(named filename: String, label: String) {
        // Try with subdirectory first
        if let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "strokedata") {
            #if DEBUG
            print("✅ Found \(filename).json in strokedata subdirectory")
            #endif
            loadFromURL(url, label: label)
            return
        }
        
        // Fallback: try without subdirectory
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            #if DEBUG
            print("✅ Found \(filename).json in main bundle")
            #endif
            loadFromURL(url, label: label)
            return
        }
        
        #if DEBUG
        print("⚠️ \(filename).json NOT FOUND - \(label) will be unavailable")
        #endif
    }
    
    private func loadFromURL(_ url: URL, label: String) {
        guard let data = try? Data(contentsOf: url) else {
            print("❌ Failed to read \(label) data from \(url.lastPathComponent)")
            return
        }
        
        guard let decoded = try? JSONDecoder().decode([String: ChineseCharacterData].self, from: data) else {
            print("❌ Failed to decode \(label) - check JSON structure")
            return
        }
        
        // Merge with existing data
        strokeData.merge(decoded) { (current, new) in new }
        print("✅ Loaded \(decoded.count) characters from \(label) (total: \(strokeData.count))")
    }
    
    /// Get stroke data for a character by codepoint
    /// - Parameter codepoint: The Unicode codepoint
    /// - Returns: Array of stroke paths, or nil if not found
    func loadStrokes(for codepoint: UInt32) -> [StrokePath]? {
        // Try with 5-digit format first (for chinese_stroke_data.json compatibility)
        let key5 = String(format: "U+%05X", codepoint)
        if let data = strokeData[key5] {
            // Convert JSON structure to StrokePath array and flip Y-axis
            return convertToStrokePaths(data.strokes, flipY: true)
        }
        
        // Fallback to 4-digit format (for chinesenumbers.json compatibility)
        let key4 = String(format: "U+%04X", codepoint)
        if let data = strokeData[key4] {
            // Convert JSON structure to StrokePath array (no Y-flip for old format)
            return convertToStrokePaths(data.strokes, flipY: false)
        }
        
        #if DEBUG
        print("⚠️ No stroke data found for codepoint U+\(String(format: "%04X", codepoint)) (tried both U+%04X and U+%05X formats)")
        #endif
        
        return nil
    }
    
    /// Convert JSON stroke data to StrokePath array
    private func convertToStrokePaths(_ jsonStrokes: [[JSONStrokePoint]], flipY: Bool) -> [StrokePath] {
        if flipY {
            // Find the max Y value to flip around
            let allYValues = jsonStrokes.flatMap { $0.map { $0.y } }
            let maxY = allYValues.max() ?? 900.0
            
            return jsonStrokes.map { stroke in
                let points = stroke.map { point in
                    StrokePoint(
                        x: Float(point.x),
                        y: Float(maxY - point.y), // Flip Y-axis
                        t: point.t
                    )
                }
                return StrokePath(points: points)
            }
        } else {
            return jsonStrokes.map { stroke in
                let points = stroke.map { point in
                    StrokePoint(
                        x: Float(point.x),
                        y: Float(point.y),
                        t: point.t
                    )
                }
                return StrokePath(points: points)
            }
        }
    }
    
    /// Get stroke data for a character by its string representation
    /// - Parameter character: The character string (e.g., "一")
    /// - Returns: Array of stroke paths, or nil if not found
    func loadStrokes(for character: String) -> [StrokePath]? {
        guard let data = strokeData.values.first(where: { $0.character == character }) else {
            return nil
        }
        
        // Determine if we should flip Y based on the key format
        let key = strokeData.first(where: { $0.value.character == character })?.key ?? ""
        let shouldFlipY = key.count > 6 // "U+04EBA" has 7 chars, "U+4EBA" has 6
        
        return convertToStrokePaths(data.strokes, flipY: shouldFlipY)
    }
    
    /// Get all available characters
    var availableCharacters: [String] {
        return strokeData.values.map { $0.character }.sorted()
    }
    
    /// Get all available codepoints
    var availableCodepoints: [UInt32] {
        return strokeData.values.map { UInt32($0.codepoint) }.sorted()
    }
}

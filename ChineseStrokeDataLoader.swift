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
        
        guard let url = Bundle.main.url(forResource: "chinesenumbers", withExtension: "json", subdirectory: "strokedata") else {
            #if DEBUG
            print("⚠️ chinesenumbers.json NOT FOUND in strokedata subdirectory")
            #endif
            
            // Try without subdirectory as fallback
            if let fallbackURL = Bundle.main.url(forResource: "chinesenumbers", withExtension: "json") {
                #if DEBUG
                print("✅ Found chinesenumbers.json in main bundle")
                #endif
                loadFromURL(fallbackURL)
                return
            }
            
            print("❌ Chinese stroke data not available")
            return
        }
        
        #if DEBUG
        print("✅ Found chinesenumbers.json at: \(url)")
        #endif
        loadFromURL(url)
    }
    
    private func loadFromURL(_ url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            print("❌ Failed to read chinesenumbers.json data")
            return
        }
        
        guard let decoded = try? JSONDecoder().decode([String: ChineseCharacterData].self, from: data) else {
            print("❌ Failed to decode chinesenumbers.json - check JSON structure")
            return
        }
        
        strokeData = decoded
        print("✅ Loaded stroke data for \(strokeData.count) Chinese characters")
    }
    
    /// Get stroke data for a character by codepoint
    /// - Parameter codepoint: The Unicode codepoint
    /// - Returns: Array of stroke paths, or nil if not found
    func loadStrokes(for codepoint: UInt32) -> [StrokePath]? {
        let key = String(format: "U+%04X", codepoint)
        guard let data = strokeData[key] else {
            return nil
        }
        
        // Convert JSON structure to StrokePath array
        return data.strokes.map { stroke in
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
    
    /// Get stroke data for a character by its string representation
    /// - Parameter character: The character string (e.g., "一")
    /// - Returns: Array of stroke paths, or nil if not found
    func loadStrokes(for character: String) -> [StrokePath]? {
        guard let data = strokeData.values.first(where: { $0.character == character }) else {
            return nil
        }
        
        // Convert JSON structure to StrokePath array
        return data.strokes.map { stroke in
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
    
    /// Get all available characters
    var availableCharacters: [String] {
        return strokeData.values.map { $0.character }.sorted()
    }
    
    /// Get all available codepoints
    var availableCodepoints: [UInt32] {
        return strokeData.values.map { UInt32($0.codepoint) }.sorted()
    }
}

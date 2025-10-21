import Foundation

/// Handles loading stroke data from JSON files on-demand to reduce memory usage
class KanaStrokeDataLoader {
    static let shared = KanaStrokeDataLoader()
    
    // MARK: - JSON Structure
    
    struct JSONStrokePoint: Codable {
        let x: Double
        let y: Double
        let t: Double
    }
    
    struct KanaCharacterData: Codable {
        let character: String
        let codepoint: Int
        let strokes: [[JSONStrokePoint]]
    }
    
    // MARK: - Cache
    
    private var strokeData: [String: KanaCharacterData] = [:]
    
    private init() {
        loadStrokeData()
    }
    
    // MARK: - Loading Methods
    
    private func loadStrokeData() {
        #if DEBUG
        print("🔍 Debug: Bundle identifier: \(Bundle.main.bundleIdentifier ?? "Unknown Bundle")")
        print("🔍 Debug: Bundle path: \(Bundle.main.bundlePath)")
        
        // Let's see what resources ARE in the bundle
        if let resourcePath = Bundle.main.resourcePath {
            print("🔍 Debug: Resource path: \(resourcePath)")
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                print("🔍 Debug: Bundle contents: \(contents.sorted())")
            }
        }
        
        // Try to find the strokedata directory specifically
        if let strokeDataURL = Bundle.main.url(forResource: nil, withExtension: nil, subdirectory: "strokedata") {
            print("✅ Debug: Found strokedata directory at: \(strokeDataURL)")
            if let strokeDataContents = try? FileManager.default.contentsOfDirectory(at: strokeDataURL, includingPropertiesForKeys: nil) {
                print("🔍 Debug: strokedata contents: \(strokeDataContents.map { $0.lastPathComponent })")
            }
        } else {
            print("❌ Debug: strokedata directory not found")
        }
        #endif
        
        guard let url = Bundle.main.url(forResource: "kanastrokes", withExtension: "json", subdirectory: "strokedata") else {
            print("❌ kanastrokes.json NOT FOUND in strokedata subdirectory")
            
            // Try without subdirectory as fallback
            if let fallbackURL = Bundle.main.url(forResource: "kanastrokes", withExtension: "json") {
                #if DEBUG
                print("✅ Debug: Found kanastrokes.json in main bundle (no subdirectory): \(fallbackURL)")
                #endif
                // Continue with this URL instead
                loadFromURL(fallbackURL)
                return
            }
            
            print("   Expected location: strokedata/kanastrokes.json")
            print("   Please ensure:")
            print("   1. The file is added to your Xcode project")
            print("   2. It's in the 'strokedata' folder")
            print("   3. It's added to your app target")
            print("   4. It's included in Build Phases → Copy Bundle Resources")
            return
        }
        
        #if DEBUG
        print("✅ Debug: Found kanastrokes.json at: \(url)")
        #endif
        loadFromURL(url)
    }
    
    private func loadFromURL(_ url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            print("❌ Failed to read kanastrokes.json data")
            return
        }
        
        guard let decoded = try? JSONDecoder().decode([String: KanaCharacterData].self, from: data) else {
            print("❌ Failed to decode kanastrokes.json - check JSON structure")
            return
        }
        
        strokeData = decoded
        print("✅ Loaded stroke data for \(strokeData.count) characters")
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
    /// - Parameter character: The character string (e.g., "あ")
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

// MARK: - Legacy Support

/// Static wrapper for compatibility with existing code
struct StrokeDataLoader {
    /// Load stroke data for a specific codepoint from bundled JSON
    /// - Parameter codepoint: The Unicode codepoint
    /// - Returns: Array of stroke paths, or nil if not found
    static func loadStrokes(for codepoint: UInt32) -> [StrokePath]? {
        return KanaStrokeDataLoader.shared.loadStrokes(for: codepoint)
    }
}

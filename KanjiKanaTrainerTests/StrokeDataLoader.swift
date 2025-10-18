import Foundation

/// Handles loading stroke data from JSON files on-demand to reduce memory usage
struct StrokeDataLoader {
    
    // MARK: - JSON Structure
    
    /// JSON structure for stroke data files
    private struct StrokeDataJSON: Codable {
        let strokes: [StrokePath]
    }
    
    // MARK: - Loading Methods
    
    /// Load stroke data for a specific codepoint from bundled JSON
    /// - Parameter codepoint: The Unicode codepoint
    /// - Returns: Array of stroke paths, or nil if not found
    static func loadStrokes(for codepoint: UInt32) -> [StrokePath]? {
        // Format: "U+3042" → "3042"
        let hexString = String(format: "%04X", codepoint)
        let filename = hexString
        
        // Try to load from bundle
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "StrokeData") else {
            return nil
        }
        
        return loadStrokes(from: url)
    }
    
    /// Load stroke data from a specific URL
    /// - Parameter url: The file URL
    /// - Returns: Array of stroke paths, or nil if loading fails
    static func loadStrokes(from url: URL) -> [StrokePath]? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let strokeData = try decoder.decode(StrokeDataJSON.self, from: data)
            return strokeData.strokes
        } catch {
            print("Failed to load stroke data from \(url.lastPathComponent): \(error)")
            return nil
        }
    }
    
    // MARK: - Batch Export (for migration)
    
    /// Export stroke data to JSON format
    /// Useful for converting existing Swift data to JSON files
    /// - Parameters:
    ///   - strokes: The stroke paths to export
    ///   - codepoint: The Unicode codepoint
    /// - Returns: JSON data
    static func exportToJSON(strokes: [StrokePath], for codepoint: UInt32) throws -> Data {
        let strokeData = StrokeDataJSON(strokes: strokes)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(strokeData)
    }
}

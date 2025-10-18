import Foundation

/// Utility for batch converting and managing stroke data JSON files
/// This is useful for:
/// - Converting existing Swift data to JSON
/// - Validating JSON files
/// - Generating batch files
struct StrokeDataConverter {
    
    // MARK: - Export
    
    /// Export a single character's stroke data to a JSON file
    /// - Parameters:
    ///   - strokes: The stroke paths
    ///   - codepoint: Unicode codepoint
    ///   - directory: Output directory URL
    static func exportToFile(strokes: [StrokePath], codepoint: UInt32, directory: URL) throws {
        let data = try StrokeDataLoader.exportToJSON(strokes: strokes, for: codepoint)
        let filename = String(format: "%04X", codepoint)
        let fileURL = directory.appendingPathComponent("\(filename).json")
        try data.write(to: fileURL)
        print("✅ Exported: \(fileURL.lastPathComponent)")
    }
    
    /// Batch export multiple characters
    /// - Parameters:
    ///   - strokeData: Dictionary mapping codepoint to stroke paths
    ///   - directory: Output directory URL
    static func batchExport(_ strokeData: [UInt32: [StrokePath]], to directory: URL) throws {
        // Create directory if it doesn't exist
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        var successCount = 0
        var failureCount = 0
        
        for (codepoint, strokes) in strokeData {
            do {
                try exportToFile(strokes: strokes, codepoint: codepoint, directory: directory)
                successCount += 1
            } catch {
                print("❌ Failed to export U+\(String(format: "%04X", codepoint)): \(error)")
                failureCount += 1
            }
        }
        
        print("\n📊 Export Summary:")
        print("   ✅ Success: \(successCount)")
        print("   ❌ Failed: \(failureCount)")
        print("   📁 Total: \(successCount + failureCount)")
    }
    
    // MARK: - Validation
    
    /// Validate all JSON files in a directory
    /// - Parameter directory: Directory containing JSON files
    /// - Returns: Array of validation results
    static func validateDirectory(_ directory: URL) throws -> [ValidationResult] {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        
        var results: [ValidationResult] = []
        
        for fileURL in files {
            let result = validateFile(fileURL)
            results.append(result)
        }
        
        return results
    }
    
    /// Validate a single JSON file
    /// - Parameter url: File URL
    /// - Returns: Validation result
    static func validateFile(_ url: URL) -> ValidationResult {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            _ = try decoder.decode(StrokeDataJSON.self, from: data)
            
            // Additional validation
            let filename = url.deletingPathExtension().lastPathComponent
            guard filename.count == 4 else {
                return ValidationResult(
                    filename: url.lastPathComponent,
                    isValid: false,
                    error: "Filename should be 4-digit hex codepoint"
                )
            }
            
            guard UInt32(filename, radix: 16) != nil else {
                return ValidationResult(
                    filename: url.lastPathComponent,
                    isValid: false,
                    error: "Filename must be valid hexadecimal"
                )
            }
            
            return ValidationResult(
                filename: url.lastPathComponent,
                isValid: true,
                error: nil
            )
        } catch {
            return ValidationResult(
                filename: url.lastPathComponent,
                isValid: false,
                error: error.localizedDescription
            )
        }
    }
    
    // MARK: - Supporting Types
    
    struct ValidationResult {
        let filename: String
        let isValid: Bool
        let error: String?
        
        var description: String {
            if isValid {
                return "✅ \(filename)"
            } else {
                return "❌ \(filename): \(error ?? "Unknown error")"
            }
        }
    }
    
    private struct StrokeDataJSON: Codable {
        let strokes: [StrokePath]
    }
}

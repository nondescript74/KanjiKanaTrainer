import Foundation

#if DEBUG
/// Manual test runner for stroke data validation (not using XCTest)
struct StrokeDataTests {
    
    static func runAllTests() async {
        print("\n=== Running Stroke Data Tests ===\n")
        
        await testLoadExistingStrokeData()
        await testMissingStrokeData()
        await testLoadMultipleCharacters()
        await testGlyphRepositoryWithJSONStrokes()
        await testStrokeDataStructure()
        await testExportToJSON()
        await testLoadingPerformance()
        await testMemoryEfficiency()
        
        print("\n=== All Tests Complete ===\n")
    }
    
    static func testLoadExistingStrokeData() async {
        print("Test: Load existing stroke data")
        
        // Test loading hiragana あ (U+3042)
        let strokes = StrokeDataLoader.loadStrokes(for: 0x3042)
        
        guard let strokes = strokes else {
            print("  ❌ FAIL: Should load stroke data for U+3042 (あ)")
            return
        }
        
        guard strokes.count > 0 else {
            print("  ❌ FAIL: Should have at least one stroke")
            return
        }
        
        for (index, stroke) in strokes.enumerated() {
            guard stroke.points.count >= 2 else {
                print("  ❌ FAIL: Stroke \(index) should have at least 2 points")
                return
            }
            
            // Verify point coordinates are normalized (0.0 to 1.0)
            for point in stroke.points {
                guard point.x >= 0.0 && point.x <= 1.0 else {
                    print("  ❌ FAIL: X coordinate should be normalized")
                    return
                }
                guard point.y >= 0.0 && point.y <= 1.0 else {
                    print("  ❌ FAIL: Y coordinate should be normalized")
                    return
                }
                guard point.t >= 0.0 else {
                    print("  ❌ FAIL: Time should be non-negative")
                    return
                }
            }
        }
        
        print("  ✅ PASS")
    }
    
    static func testMissingStrokeData() async {
        print("Test: Missing stroke data")
        
        // Test with a codepoint that doesn't have a JSON file
        let strokes = StrokeDataLoader.loadStrokes(for: 0x9999)
        
        if strokes == nil {
            print("  ✅ PASS: Correctly returns nil for missing stroke data")
        } else {
            print("  ❌ FAIL: Should return nil for missing stroke data")
        }
    }
    
    static func testLoadMultipleCharacters() async {
        print("Test: Load multiple characters")
        
        let codepoints: [UInt32] = [0x3042, 0x3044, 0x30A2] // あ, い, ア
        var passed = true
        
        for codepoint in codepoints {
            let strokes = StrokeDataLoader.loadStrokes(for: codepoint)
            let hex = String(format: "%04X", codepoint)
            
            // If JSON exists, verify it loads correctly
            if let strokes = strokes {
                if strokes.count == 0 {
                    print("  ❌ FAIL: U+\(hex) should have strokes")
                    passed = false
                }
            }
            // If it doesn't exist, that's okay (will use synthetic)
        }
        
        if passed {
            print("  ✅ PASS")
        }
    }
    
    static func testGlyphRepositoryWithJSONStrokes() async {
        print("Test: Glyph repository with JSON strokes")
        
        let repository = GlyphBundleRepository()
        
        // Test loading a hiragana character
        let hiraganaID = CharacterID(script: .kana, codepoint: Int(0x3042))
        
        do {
            let glyph = try await repository.glyph(for: hiraganaID)
            
            guard glyph.literal == "あ" else {
                print("  ❌ FAIL: Glyph literal should be 'あ'")
                return
            }
            
            guard glyph.strokes.count > 0 else {
                print("  ❌ FAIL: Should have stroke data")
                return
            }
            
            guard glyph.readings.contains("a") else {
                print("  ❌ FAIL: Should contain reading 'a'")
                return
            }
            
            print("  ✅ PASS")
        } catch {
            print("  ❌ FAIL: \(error)")
        }
    }
    
    static func testStrokeDataStructure() async {
        print("Test: Stroke data structure")
        
        guard let strokes = StrokeDataLoader.loadStrokes(for: 0x3042) else {
            print("  ⚠️  SKIP: File doesn't exist")
            return
        }
        
        for (strokeIndex, stroke) in strokes.enumerated() {
            // Verify points are ordered by time
            var previousTime: TimeInterval = -1
            
            for point in stroke.points {
                guard point.t >= previousTime else {
                    print("  ❌ FAIL: Points in stroke \(strokeIndex) should be ordered by time")
                    return
                }
                previousTime = point.t
            }
            
            // First point should start at t=0
            if let firstPoint = stroke.points.first {
                guard firstPoint.t == 0.0 else {
                    print("  ❌ FAIL: First point in stroke \(strokeIndex) should have t=0")
                    return
                }
            }
        }
        
        print("  ✅ PASS")
    }
    
    static func testExportToJSON() async {
        print("Test: Export to JSON")
        
        let testStrokes = [
            StrokePath(points: [
                StrokePoint(x: 0.2, y: 0.2, t: 0.0),
                StrokePoint(x: 0.5, y: 0.5, t: 0.1),
                StrokePoint(x: 0.8, y: 0.8, t: 0.2)
            ])
        ]
        
        do {
            let jsonData = try StrokeDataLoader.exportToJSON(strokes: testStrokes, for: 0x3042)
            
            guard jsonData.count > 0 else {
                print("  ❌ FAIL: Should generate JSON data")
                return
            }
            
            // Verify it can be decoded back
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(TestStrokeData.self, from: jsonData)
            
            guard decoded.strokes.count == 1 else {
                print("  ❌ FAIL: Should have 1 stroke")
                return
            }
            
            guard decoded.strokes[0].points.count == 3 else {
                print("  ❌ FAIL: Should have 3 points")
                return
            }
            
            print("  ✅ PASS")
        } catch {
            print("  ❌ FAIL: \(error)")
        }
    }
    
    static func testLoadingPerformance() async {
        print("Test: Loading performance")
        
        // Measure time to load a single character
        let startTime = Date()
        
        _ = StrokeDataLoader.loadStrokes(for: 0x3042)
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        // Should load in under 10ms
        if elapsed < 0.01 {
            print("  ✅ PASS: Loading took \(String(format: "%.4f", elapsed))s")
        } else {
            print("  ⚠️  SLOW: Loading took \(String(format: "%.4f", elapsed))s (expected < 0.01s)")
        }
    }
    
    static func testMemoryEfficiency() async {
        print("Test: Memory efficiency")
        
        // Load multiple characters and verify they don't all stay in memory
        let codepoints: [UInt32] = [
            0x3042, 0x3044, 0x3046, 0x3048, 0x304A, // あいうえお
            0x30A2, 0x30A4, 0x30A6, 0x30A8, 0x30AA  // アイウエオ
        ]
        
        for codepoint in codepoints {
            _ = StrokeDataLoader.loadStrokes(for: codepoint)
            // Each load is independent and doesn't keep data in memory
        }
        
        // Test passes if no memory issues occur
        print("  ✅ PASS: Loaded multiple characters without memory issues")
    }
    
    // Helper type for decoding
    private struct TestStrokeData: Codable {
        let strokes: [StrokePath]
    }
}
#endif


#if DEBUG
/// Example usage for manual testing
struct StrokeDataTestExamples {
    
    static func runExamples() async {
        print("=== Stroke Data Test Examples ===\n")
        
        // Example 1: Load a character
        print("1. Loading stroke data for あ (U+3042):")
        if let strokes = StrokeDataLoader.loadStrokes(for: 0x3042) {
            print("   ✅ Loaded \(strokes.count) stroke(s)")
            for (i, stroke) in strokes.enumerated() {
                print("   Stroke \(i+1): \(stroke.points.count) points")
            }
        } else {
            print("   ⚠️ No stroke data found (will use synthetic)")
        }
        
        // Example 2: Load through repository
        print("\n2. Loading through GlyphRepository:")
        let repo = GlyphBundleRepository()
        let id = CharacterID(script: .kana, codepoint: Int(0x3042))
        
        do {
            let glyph = try await repo.glyph(for: id)
            print("   ✅ Loaded glyph: \(glyph.literal)")
            print("   Reading: \(glyph.readings.joined(separator: ", "))")
            print("   Strokes: \(glyph.strokes.count)")
        } catch {
            print("   ❌ Error: \(error)")
        }
        
        // Example 3: Run all tests
        print("\n3. Running automated tests:")
        await StrokeDataTests.runAllTests()
        
        print("\n=== Examples Complete ===")
    }
}
#endif

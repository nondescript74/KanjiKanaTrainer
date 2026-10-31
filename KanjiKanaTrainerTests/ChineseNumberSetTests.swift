import Foundation
import Testing
@testable import KanjiKanaTrainer

struct ChineseNumberSetTests {

    private let repo = GlyphBundleRepository()

    private func literals(_ numbers: ClosedRange<Int>) async throws -> [String] {
        var out: [String] = []
        for id in ChineseNumberIDs.range(numbers) {
            out.append(try await repo.glyph(for: id).literal)
        }
        return out
    }

    @Test func elevenToNineteenShowsTheTeenNumbers() async throws {
        #expect(try await literals(11...19) == ["十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九"])
    }

    @Test func twentyToThirtyShowsTwentyThroughThirty() async throws {
        let got = try await literals(20...30)
        #expect(got.count == 11)
        #expect(got.first == "二十")
        #expect(got[3] == "二十三")
        #expect(got.last == "三十")
    }

    @Test func oneToThirtyCountsInOrder() async throws {
        let got = try await literals(1...30)
        #expect(got.count == 30)
        #expect(got[0] == "一")
        #expect(got[9] == "十")
        #expect(got[10] == "十一")
        #expect(got[29] == "三十")
    }

    @Test func zeroToTenStaysSingleCharacters() async throws {
        #expect(try await literals(0...10) == ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"])
    }
}

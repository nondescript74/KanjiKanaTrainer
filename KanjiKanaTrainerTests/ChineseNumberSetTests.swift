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

struct CompoundLayoutTests {

    private let repo = GlyphBundleRepository()

    private func xRange(_ strokes: [StrokePath]) -> ClosedRange<Float> {
        let xs = strokes.flatMap { $0.points.map(\.x) }
        return xs.min()!...xs.max()!
    }

    @Test func componentsSitSideBySideNotOnTopOfEachOther() {
        let unit = [StrokePath(points: [StrokePoint(x: 0, y: 0.5, t: 0), StrokePoint(x: 1, y: 0.5, t: 0.1)])]
        let laid = CompoundLayout.sideBySide([unit, unit, unit])
        #expect(laid.count == 3)
        #expect(laid[0].points[0].x == 0)
        #expect(laid[1].points[0].x == 1 + CompoundLayout.gap)
        #expect(laid[2].points[0].x == 2 * (1 + CompoundLayout.gap))
        #expect(laid.allSatisfy { $0.points.allSatisfy { $0.y == 0.5 } })
    }

    @Test func elevenHasTenThenOneToItsRight() async throws {
        let glyph = try await repo.glyph(for: ChineseNumberIDs.id(for: 11))
        #expect(glyph.strokes.count == 3) // 十 (2) + 一 (1)
        let ten = Array(glyph.strokes.prefix(2))
        let one = Array(glyph.strokes.suffix(1))
        #expect(xRange(one).lowerBound > xRange(ten).upperBound)
    }

    @Test func twentyThreeHasThreeCellsInOrder() async throws {
        let glyph = try await repo.glyph(for: ChineseNumberIDs.id(for: 23))
        #expect(glyph.strokes.count == 7) // 二 (2) + 十 (2) + 三 (3)
        let two = xRange(Array(glyph.strokes[0..<2]))
        let ten = xRange(Array(glyph.strokes[2..<4]))
        let three = xRange(Array(glyph.strokes[4..<7]))
        #expect(two.upperBound < ten.lowerBound)
        #expect(ten.upperBound < three.lowerBound)
    }
}

//
//  PracticeViewModel.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 10/17/25.
//

//
import Foundation
import PencilKit
import Combine

@MainActor
final class PracticeViewModel: ObservableObject {
    let glyph: CharacterGlyph
    private let env: AppEnvironment
    @Published var score: PracticeScore?
    @Published var progress: CharacterProgress?

    init(glyph: CharacterGlyph, env: AppEnvironment) {
        self.glyph = glyph
        self.env = env
        self.progress = try? env.progress.progress(for: glyph.id)
    }

    func clearScore() {
        score = nil
    }

    func evaluate(_ drawing: PKDrawing) {
        let strokes = drawing.strokes.map { stroke -> StrokePath in
            let points = stroke.path.map {
                StrokePoint(x: Float($0.location.x),
                            y: Float($0.location.y),
                            t: TimeInterval(Float($0.timeOffset)))
            }
            return StrokePath(points: points)
        }

        let attemptScore = env.evaluator.evaluate(user: strokes, ideal: glyph.strokes)
        score = attemptScore
        record(attemptScore, for: glyph)
    }

    private func record(_ attemptScore: PracticeScore, for glyph: CharacterGlyph) {
        do {
            try env.progress.record(glyph: glyph, score: attemptScore)
            progress = try env.progress.progress(for: glyph.id)
        } catch {
            print("⚠️ Could not save progress: \(error)")
        }
    }
}


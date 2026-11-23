//
//  SetProgressViews.swift
//  KanjiKanaTrainer
//
//  Small pieces shown on the set lists: the "Up next" badge and a set's stars.
//

import SwiftUI

/// A small capsule beside the set to do next.
struct UpNextBadge: View {
    var body: some View {
        Text("Up next")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(Color.orange))
            .accessibilityLabel("Up next")
    }
}

/// Filled and empty stars, up to `StarRating.maxStars`.
struct StarsView: View {
    let stars: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<StarRating.maxStars, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .foregroundStyle(index < stars ? Color.yellow : Color.secondary.opacity(0.5))
            }
        }
        .font(.caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(stars) of \(StarRating.maxStars) stars")
    }
}

/// A practice set's stars and how many of its characters have been tried.
struct SetStarsView: View {
    let summary: SetProgressSummary

    var body: some View {
        HStack(spacing: 6) {
            StarsView(stars: summary.stars)
            Text("\(summary.practised) of \(summary.total) tried")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        UpNextBadge()
        StarsView(stars: 2)
        SetStarsView(summary: SetProgressSummary(bestScores: [0.95, 0.85, nil]))
    }
    .padding()
}

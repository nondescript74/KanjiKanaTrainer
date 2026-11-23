//
//  NumberGameView.swift
//  KanjiKanaTrainer
//
//  Number game screen: hear or see a Chinese number, tap the match.
//

import SwiftUI

struct NumberGameView: View {
    @StateObject private var model = NumberGameViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                settings
                promptCard
                choiceGrid
                feedback
                scoreLine
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Number Game")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if model.mode == .listen { model.say() }
        }
        .onDisappear {
            model.stop()
        }
    }

    // MARK: - Parts

    private var settings: some View {
        VStack(spacing: 10) {
            Picker("Game", selection: $model.mode) {
                ForEach(NumberGameMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Picker("Numbers", selection: $model.range) {
                ForEach(NumberGameRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)

            Picker("Voice", selection: $model.voice) {
                ForEach(ChineseVoice.allCases) { voice in
                    Text(voice.title).tag(voice)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var promptCard: some View {
        VStack(spacing: 12) {
            Text(model.mode.instruction)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            switch model.mode {
            case .listen:
                Button {
                    model.say()
                } label: {
                    Label("Hear it", systemImage: "speaker.wave.3.fill")
                        .font(.title2.weight(.semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.blue.opacity(0.15)))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            case .read:
                Text(ChineseNumerals.literal(for: model.question.answer))
                    .font(.system(size: 72, weight: .light))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            case .find:
                Text("\(model.question.answer)")
                    .font(.system(size: 72, weight: .semibold, design: .rounded))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var choiceGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(model.question.choices, id: \.self) { choice in
                Button {
                    model.pick(choice)
                } label: {
                    Text(model.label(for: choice, inChinese: model.mode.choicesInChinese))
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(fill(for: choice))
                        )
                        .foregroundStyle(.primary)
                }
                .buttonStyle(CardButtonStyle())
                .disabled(model.answered)
            }
        }
    }

    @ViewBuilder
    private var feedback: some View {
        if model.answered {
            VStack(spacing: 12) {
                if model.answeredRight {
                    Label("Right!", systemImage: "checkmark.circle.fill")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                } else {
                    Label(
                        "It was \(model.question.answer), \(ChineseNumerals.literal(for: model.question.answer))",
                        systemImage: "arrow.uturn.backward.circle.fill"
                    )
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.orange)
                }

                Button {
                    model.next()
                } label: {
                    Text("Next")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.blue))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var scoreLine: some View {
        HStack {
            Label("\(model.correctCount) of \(model.answeredCount)", systemImage: "checkmark.seal")
            Spacer()
            Label("\(model.streak) in a row", systemImage: "flame.fill")
                .foregroundStyle(model.streak >= 3 ? Color.orange : Color.secondary)
            Spacer()
            Label("Best \(model.bestStreak)", systemImage: "star.fill")
                .foregroundStyle(.yellow)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private func fill(for choice: Int) -> Color {
        guard model.answered else { return Color.blue.opacity(0.1) }
        if choice == model.question.answer { return Color.green.opacity(0.35) }
        if choice == model.picked { return Color.red.opacity(0.3) }
        return Color.gray.opacity(0.1)
    }
}

#Preview {
    NavigationStack {
        NumberGameView()
    }
}

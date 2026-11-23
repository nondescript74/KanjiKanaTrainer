//
//  FamilyTree.swift
//  KanjiKanaTrainer
//
//  Family tree: tap a relative, watch the name drawn, hear it said.
//  Every character here already has stroke data (the family sets).
//

import SwiftUI

/// One person on the tree, by the word a child would call them.
struct FamilyMember: Identifiable, Hashable {
    /// What you call them, e.g. 外婆.
    let word: String
    /// Mandarin reading, e.g. wàipó.
    let pinyin: String
    /// English, e.g. "Grandma (Mom's mom)".
    let english: String
    var isMe: Bool = false

    var id: String { word }

    /// The different characters in the word, in order (爸爸 → 爸, 外婆 → 外 婆).
    var codepoints: [Int] {
        var seen: Set<UInt32> = []
        var out: [Int] = []
        for scalar in word.unicodeScalars where !seen.contains(scalar.value) {
            seen.insert(scalar.value)
            out.append(Int(scalar.value))
        }
        return out
    }

    var glyphIDs: [CharacterID] {
        codepoints.map { CharacterID(script: .hanzi, codepoint: $0) }
    }
}

enum FamilyTree {
    struct Generation: Identifiable {
        let title: String
        let members: [FamilyMember]
        var id: String { title }
    }

    /// Dad's side on the left, Mom's side on the right.
    static let generations: [Generation] = [
        Generation(title: "Grandparents", members: [
            FamilyMember(word: "爷爷", pinyin: "yéye", english: "Grandpa (Dad's dad)"),
            FamilyMember(word: "奶奶", pinyin: "nǎinai", english: "Grandma (Dad's mom)"),
            FamilyMember(word: "外公", pinyin: "wàigōng", english: "Grandpa (Mom's dad)"),
            FamilyMember(word: "外婆", pinyin: "wàipó", english: "Grandma (Mom's mom)"),
        ]),
        Generation(title: "Parents, aunts and uncles", members: [
            FamilyMember(word: "姑姑", pinyin: "gūgu", english: "Aunt (Dad's sister)"),
            FamilyMember(word: "叔叔", pinyin: "shūshu", english: "Uncle (Dad's younger brother)"),
            FamilyMember(word: "爸爸", pinyin: "bàba", english: "Dad"),
            FamilyMember(word: "妈妈", pinyin: "māma", english: "Mom"),
            FamilyMember(word: "姨妈", pinyin: "yímā", english: "Aunt (Mom's sister)"),
            FamilyMember(word: "舅舅", pinyin: "jiùjiu", english: "Uncle (Mom's brother)"),
        ]),
        Generation(title: "Me, brothers and sisters", members: [
            FamilyMember(word: "哥哥", pinyin: "gēge", english: "Older brother"),
            FamilyMember(word: "姐姐", pinyin: "jiějie", english: "Older sister"),
            FamilyMember(word: "我", pinyin: "wǒ", english: "Me", isMe: true),
            FamilyMember(word: "弟弟", pinyin: "dìdi", english: "Younger brother"),
            FamilyMember(word: "妹妹", pinyin: "mèimei", english: "Younger sister"),
        ]),
        Generation(title: "My children", members: [
            FamilyMember(word: "儿子", pinyin: "érzi", english: "Son"),
            FamilyMember(word: "女儿", pinyin: "nǚ'ér", english: "Daughter"),
        ]),
    ]

    static var allMembers: [FamilyMember] { generations.flatMap(\.members) }
}

// MARK: - Screen

struct FamilyTreeView: View {
    let env: AppEnvironment
    @State private var voice: ChineseVoice = .mandarin

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("Tap a person to watch their name written. Tap the speaker to hear it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Picker("Voice", selection: $voice) {
                    ForEach(ChineseVoice.allCases) { voice in
                        Text(voice.title).tag(voice)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Label("Dad's side", systemImage: "arrow.left")
                    Spacer()
                    Label("Mom's side", systemImage: "arrow.right")
                        .labelStyle(TrailingIconLabelStyle())
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                ForEach(Array(FamilyTree.generations.enumerated()), id: \.element.id) { index, generation in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(generation.title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        HStack(alignment: .top, spacing: 6) {
                            ForEach(generation.members) { member in
                                FamilyMemberCard(member: member, env: env, voice: voice)
                            }
                        }
                    }
                    if index < FamilyTree.generations.count - 1 {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Family Tree")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            SpeechSynthesizerManager.shared.stopSpeaking()
        }
    }
}

private struct FamilyMemberCard: View {
    let member: FamilyMember
    let env: AppEnvironment
    let voice: ChineseVoice

    var body: some View {
        VStack(spacing: 4) {
            NavigationLink {
                SequentialDemoView(viewModel: SequentialDemoViewModel(
                    glyphIDs: member.glyphIDs,
                    env: env,
                    playsOnAppear: true
                ))
            } label: {
                VStack(spacing: 2) {
                    Text(member.word)
                        .font(.system(size: 30))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(member.pinyin)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(member.english)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, minHeight: 104, alignment: .top)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(member.isMe ? Color.orange.opacity(0.2) : Color.blue.opacity(0.1))
                )
            }
            .buttonStyle(CardButtonStyle())

            Button {
                SpeechSynthesizerManager.shared.speak(member.word, language: voice.language, rate: 0.4)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.body)
                    .frame(width: 40, height: 32)
                    .background(Capsule().fill(Color.blue.opacity(0.1)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.blue)
            .accessibilityLabel("Say \(member.english)")
        }
        .frame(maxWidth: .infinity)
    }
}

/// Puts a label's icon after its text (for "Mom's side →").
private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}

#Preview {
    NavigationStack {
        FamilyTreeView(env: AppEnvironment(
            glyphs: GlyphBundleRepository(),
            progress: SwiftDataProgressStore(inMemory: true),
            evaluator: DefaultAttemptEvaluator()
        ))
    }
}

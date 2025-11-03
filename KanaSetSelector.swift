//
//  KanaSetSelector.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// View that presents different Kana practice sets (Hiragana or Katakana)
struct KanaSetSelector: View {
    let env: AppEnvironment
    let script: RootView.KanaScript
    
    enum KanaSet: String, CaseIterable, Identifiable {
        case vowels = "Vowels (あいうえお / アイウエオ)"
        case kRow = "K-Row (か行 / カ行)"
        case sRow = "S-Row (さ行 / サ行)"
        case tRow = "T-Row (た行 / タ行)"
        case nRow = "N-Row (な行 / ナ行)"
        case hRow = "H-Row (は行 / ハ行)"
        case mRow = "M-Row (ま行 / マ行)"
        case yRow = "Y-Row (や行 / ヤ行)"
        case rRow = "R-Row (ら行 / ラ行)"
        case wRow = "W-Row + N (わ行 + ん / ワ行 + ン)"
        case complete = "Complete Set (All 46)"
        
        var id: String { rawValue }
        
        func title(isHiragana: Bool) -> String {
            switch self {
            case .vowels: return "Vowels (a, i, u, e, o)"
            case .kRow: return "K-Row (ka, ki, ku, ke, ko)"
            case .sRow: return "S-Row (sa, shi, su, se, so)"
            case .tRow: return "T-Row (ta, chi, tsu, te, to)"
            case .nRow: return "N-Row (na, ni, nu, ne, no)"
            case .hRow: return "H-Row (ha, hi, fu, he, ho)"
            case .mRow: return "M-Row (ma, mi, mu, me, mo)"
            case .yRow: return "Y-Row (ya, yu, yo)"
            case .rRow: return "R-Row (ra, ri, ru, re, ro)"
            case .wRow: return "W-Row + N (wa, wo, n)"
            case .complete: return isHiragana ? "Complete Hiragana" : "Complete Katakana"
            }
        }
        
        func description(isHiragana: Bool) -> String {
            if isHiragana {
                switch self {
                case .vowels: return "あ い う え お"
                case .kRow: return "か き く け こ"
                case .sRow: return "さ し す せ そ"
                case .tRow: return "た ち つ て と"
                case .nRow: return "な に ぬ ね の"
                case .hRow: return "は ひ ふ へ ほ"
                case .mRow: return "ま み む め も"
                case .yRow: return "や ゆ よ"
                case .rRow: return "ら り る れ ろ"
                case .wRow: return "わ を ん"
                case .complete: return "All 46 basic hiragana characters"
                }
            } else {
                switch self {
                case .vowels: return "ア イ ウ エ オ"
                case .kRow: return "カ キ ク ケ コ"
                case .sRow: return "サ シ ス セ ソ"
                case .tRow: return "タ チ ツ テ ト"
                case .nRow: return "ナ ニ ヌ ネ ノ"
                case .hRow: return "ハ ヒ フ ヘ ホ"
                case .mRow: return "マ ミ ム メ モ"
                case .yRow: return "ヤ ユ ヨ"
                case .rRow: return "ラ リ ル レ ロ"
                case .wRow: return "ワ ヲ ン"
                case .complete: return "All 46 basic katakana characters"
                }
            }
        }
        
        var icon: String {
            switch self {
            case .vowels: return "character.bubble"
            case .kRow: return "k.circle.fill"
            case .sRow: return "s.circle.fill"
            case .tRow: return "t.circle.fill"
            case .nRow: return "n.circle.fill"
            case .hRow: return "h.circle.fill"
            case .mRow: return "m.circle.fill"
            case .yRow: return "y.circle.fill"
            case .rRow: return "r.circle.fill"
            case .wRow: return "w.circle.fill"
            case .complete: return "checkmark.seal.fill"
            }
        }
        
        var characterCount: Int {
            switch self {
            case .vowels: return 5
            case .kRow, .sRow, .tRow, .nRow, .hRow, .mRow, .rRow: return 5
            case .yRow, .wRow: return 3
            case .complete: return 46
            }
        }
        
        func createViewModel(env: AppEnvironment, isHiragana: Bool) -> SequentialPracticeViewModel {
            if isHiragana {
                switch self {
                case .vowels: return .hiraganaVowels(env: env)
                case .kRow: return .hiraganaKRow(env: env)
                case .sRow: return .hiraganaSRow(env: env)
                case .tRow: return .hiraganaTRow(env: env)
                case .nRow: return .hiraganaNRow(env: env)
                case .hRow: return .hiraganaHRow(env: env)
                case .mRow: return .hiraganaMRow(env: env)
                case .yRow: return .hiraganaYRow(env: env)
                case .rRow: return .hiraganaRRow(env: env)
                case .wRow: return .hiraganaWRow(env: env)
                case .complete: return .hiraganaComplete(env: env)
                }
            } else {
                switch self {
                case .vowels: return .katakanaVowels(env: env)
                case .kRow: return .katakanaKRow(env: env)
                case .sRow: return .katakanaSRow(env: env)
                case .tRow: return .katakanaTRow(env: env)
                case .nRow: return .katakanaNRow(env: env)
                case .hRow: return .katakanaHRow(env: env)
                case .mRow: return .katakanaMRow(env: env)
                case .yRow: return .katakanaYRow(env: env)
                case .rRow: return .katakanaRRow(env: env)
                case .wRow: return .katakanaWRow(env: env)
                case .complete: return .katakanaComplete(env: env)
                }
            }
        }
    }
    
    private var isHiragana: Bool {
        script == .hiragana
    }
    
    var body: some View {
        List {
            Section {
                SequentialPracticeHelp.SetSelectorBanner(scriptName: script.rawValue)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section("Basic Sounds") {
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.vowels.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .vowels, isHiragana: isHiragana)
                }
            }
            
            Section("K-S-T Rows") {
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.kRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .kRow, isHiragana: isHiragana)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.sRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .sRow, isHiragana: isHiragana)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.tRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .tRow, isHiragana: isHiragana)
                }
            }
            
            Section("N-H-M Rows") {
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.nRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .nRow, isHiragana: isHiragana)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.hRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .hRow, isHiragana: isHiragana)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.mRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .mRow, isHiragana: isHiragana)
                }
            }
            
            Section("Y-R-W Rows") {
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.yRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .yRow, isHiragana: isHiragana)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.rRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .rRow, isHiragana: isHiragana)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.wRow.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .wRow, isHiragana: isHiragana)
                }
            }
            
            Section("Complete Set") {
                NavigationLink {
                    SequentialPracticeView(viewModel: KanaSet.complete.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    KanaSetRow(set: .complete, isHiragana: isHiragana)
                }
            }
        }
        .navigationTitle(isHiragana ? "Hiragana Sets" : "Katakana Sets")
    }
}

/// Row view for a kana set option
struct KanaSetRow: View {
    let set: KanaSetSelector.KanaSet
    let isHiragana: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: set.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(set.title(isHiragana: isHiragana))
                    .font(.headline)
                
                Text(set.description(isHiragana: isHiragana))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("\(set.characterCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            KanaSetSelector(
                env: AppEnvironment(
                    glyphs: GlyphBundleRepository(),
                    progress: SwiftDataProgressStore(),
                    evaluator: DefaultAttemptEvaluator()
                ),
                script: .hiragana
            )
        }
    } else {
        // Fallback on earlier versions
    }
}

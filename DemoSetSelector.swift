//
//  DemoSetSelector.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// View that presents different Kana demo sets (Hiragana or Katakana)
struct DemoSetSelector: View {
    let env: AppEnvironment
    let script: RootView.KanaScript
    
    enum DemoSet: String, CaseIterable, Identifiable {
        case vowels = "Vowels"
        case complete = "Complete Set"
        
        var id: String { rawValue }
        
        func title(isHiragana: Bool) -> String {
            switch self {
            case .vowels: return "Vowels (a, i, u, e, o)"
            case .complete: return isHiragana ? "Complete Hiragana (All 46)" : "Complete Katakana (All 46)"
            }
        }
        
        func description(isHiragana: Bool) -> String {
            if isHiragana {
                switch self {
                case .vowels: return "あ い う え お"
                case .complete: return "All 46 basic hiragana characters"
                }
            } else {
                switch self {
                case .vowels: return "ア イ ウ エ オ"
                case .complete: return "All 46 basic katakana characters"
                }
            }
        }
        
        var icon: String {
            switch self {
            case .vowels: return "play.circle.fill"
            case .complete: return "play.rectangle.on.rectangle.fill"
            }
        }
        
        var characterCount: Int {
            switch self {
            case .vowels: return 5
            case .complete: return 46
            }
        }
        
        func createViewModel(env: AppEnvironment, isHiragana: Bool) -> SequentialDemoViewModel {
            if isHiragana {
                switch self {
                case .vowels: return .hiraganaVowels(env: env)
                case .complete: return .hiraganaComplete(env: env)
                }
            } else {
                switch self {
                case .vowels: return .katakanaVowels(env: env)
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
                DemoHelpBanner(scriptName: script.rawValue)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section("Quick Start") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.vowels.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    DemoSetRow(set: .vowels, isHiragana: isHiragana)
                }
            }
            
            Section("Complete Set") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.complete.createViewModel(env: env, isHiragana: isHiragana))
                } label: {
                    DemoSetRow(set: .complete, isHiragana: isHiragana)
                }
            }
        }
        .navigationTitle(isHiragana ? "Hiragana Demos" : "Katakana Demos")
    }
}

/// Row view for a demo set option
struct DemoSetRow: View {
    let set: DemoSetSelector.DemoSet
    let isHiragana: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: set.icon)
                .font(.title2)
                .foregroundStyle(.green)
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

/// Help banner for demo set selector
struct DemoHelpBanner: View {
    let scriptName: String
    @AppStorage("hasSeenDemoHelp") private var hasSeenHelp = false
    @State private var isExpanded = false
    
    var body: some View {
        if !hasSeenHelp || isExpanded {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundStyle(.green)
                    Text("Sequential Demo - \(scriptName)")
                        .font(.headline)
                    Spacer()
                    Button {
                        withAnimation {
                            if !hasSeenHelp {
                                hasSeenHelp = true
                            }
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                if !hasSeenHelp || isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        DemoHelpRow(icon: "play.fill", text: "Watch stroke-by-stroke demonstrations")
                        DemoHelpRow(icon: "arrow.right.circle", text: "Characters shown one after another in sequence")
                        DemoHelpRow(icon: "repeat.circle", text: "Use auto-play to watch continuously")
                        DemoHelpRow(icon: "speaker.wave.2", text: "Hear pronunciation after each demo")
                    }
                    .padding(.top, 4)
                    
                    if !hasSeenHelp {
                        Button {
                            withAnimation {
                                hasSeenHelp = true
                            }
                        } label: {
                            Text("Got it!")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.green)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        } else {
            Button {
                withAnimation {
                    isExpanded = true
                }
            } label: {
                HStack {
                    Image(systemName: "questionmark.circle")
                    Text("Show Help")
                        .font(.caption)
                }
                .foregroundStyle(.green)
            }
            .padding(.horizontal)
        }
    }
}

struct DemoHelpRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            DemoSetSelector(
                env: AppEnvironment(
                    glyphs: GlyphBundleRepository(),
                    progress: SwiftDataProgressStore(),
                    evaluator: DefaultAttemptEvaluator()
                ),
                script: .hiragana
            )
        }
    }
}

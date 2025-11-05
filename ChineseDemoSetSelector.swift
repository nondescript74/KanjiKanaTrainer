//
//  ChineseDemoSetSelector.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// View that presents different Chinese number demo sets
struct ChineseDemoSetSelector: View {
    let env: AppEnvironment
    
    enum DemoSet: String, CaseIterable, Identifiable {
        case numbers1to10 = "1-10"
        case bodyParts = "body"
        case nature = "nature"
        case sizeDirection = "size"
        case objects = "objects"
        case pronouns = "pronouns"
        case verbs = "verbs"
        case commonWords = "common"
        case all100 = "all100"
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .numbers1to10: return "Numbers 1-10"
            case .bodyParts: return "Body Parts & People"
            case .nature: return "Nature & Elements"
            case .sizeDirection: return "Size & Direction"
            case .objects: return "Objects & Animals"
            case .pronouns: return "Pronouns & Common Words"
            case .verbs: return "Common Verbs"
            case .commonWords: return "More Common Words"
            case .all100: return "All 100 Common Characters"
            }
        }
        
        var description: String {
            switch self {
            case .numbers1to10: return "一, 二, 三, 四, 五, 六, 七, 八, 九, 十"
            case .bodyParts: return "人, 口, 手, 目, 耳, 心, 女, 子"
            case .nature: return "日, 月, 水, 火, 木, 金, 土, 天, 地, 山..."
            case .sizeDirection: return "大, 小, 中, 上, 下, 左, 右, 长, 多, 少, 高"
            case .objects: return "门, 马, 牛, 羊, 鸟, 鱼, 米, 竹..."
            case .pronouns: return "不, 也, 了, 在, 有, 我, 你, 他, 她, 好"
            case .verbs: return "来, 去, 出, 入, 吃, 喝, 看, 听, 说, 读..."
            case .commonWords: return "本, 白, 红, 开, 生, 学, 工, 用"
            case .all100: return "Complete set of 100 essential characters"
            }
        }
        
        var icon: String {
            switch self {
            case .numbers1to10: return "1.circle.fill"
            case .bodyParts: return "person.fill"
            case .nature: return "leaf.fill"
            case .sizeDirection: return "arrow.up.left.and.arrow.down.right"
            case .objects: return "cube.fill"
            case .pronouns: return "bubble.left.fill"
            case .verbs: return "figure.walk"
            case .commonWords: return "book.fill"
            case .all100: return "star.fill"
            }
        }
        
        var characterCount: Int {
            switch self {
            case .numbers1to10: return 10
            case .bodyParts: return 8
            case .nature: return 17
            case .sizeDirection: return 11
            case .objects: return 18
            case .pronouns: return 10
            case .verbs: return 18
            case .commonWords: return 8
            case .all100: return 100
            }
        }
        
        func createViewModel(env: AppEnvironment) -> SequentialDemoViewModel {
            switch self {
            case .numbers1to10: return .chineseNumbers1to10(env: env)
            case .bodyParts: return .chineseBodyParts(env: env)
            case .nature: return .chineseNature(env: env)
            case .sizeDirection: return .chineseSizeDirection(env: env)
            case .objects: return .chineseObjects(env: env)
            case .pronouns: return .chinesePronouns(env: env)
            case .verbs: return .chineseVerbs(env: env)
            case .commonWords: return .chineseCommonWords(env: env)
            case .all100: return .chineseCommonAll(env: env)
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                DemoHelpBanner(scriptName: "Chinese Characters")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section("Numbers") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers1to10.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers1to10)
                }
            }
            
            Section("Basic Characters") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.bodyParts.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .bodyParts)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.nature.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .nature)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.sizeDirection.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .sizeDirection)
                }
            }
            
            Section("Daily Life") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.objects.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .objects)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.pronouns.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .pronouns)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.verbs.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .verbs)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.commonWords.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .commonWords)
                }
            }
            
            Section("Complete Set") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.all100.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .all100)
                }
            }
        }
        .navigationTitle("Chinese Character Demos")
    }
}

/// Row view for a Chinese number demo set option
struct ChineseDemoSetRow: View {
    let set: ChineseDemoSetSelector.DemoSet
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: set.icon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(set.title)
                    .font(.headline)
                
                Text(set.description)
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
            ChineseDemoSetSelector(env: AppEnvironment(
                glyphs: GlyphBundleRepository(),
                progress: SwiftDataProgressStore(),
                evaluator: DefaultAttemptEvaluator()
            ))
        }
    }
}

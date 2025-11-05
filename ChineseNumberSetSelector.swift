//
//  ChineseNumberSetSelector.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/2/25.
//

import SwiftUI

/// View that presents different Chinese number practice sets
struct ChineseNumberSetSelector: View {
    let env: AppEnvironment
    
    enum NumberSet: String, CaseIterable, Identifiable {
        case numbers0to10 = "0-10"
        case numbers1to10 = "1-10"
        case numbers11to19 = "11-19"
        case numbers20to30 = "20-30"
        case numbers1to30 = "1-30 (All)"
        case largeNumbers = "Large Numbers (十, 百, 千, 万, 億)"
        // New common character sets
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
            case .numbers0to10: return "Numbers 0-10"
            case .numbers1to10: return "Numbers 1-10"
            case .numbers11to19: return "Numbers 11-19"
            case .numbers20to30: return "Numbers 20-30"
            case .numbers1to30: return "Numbers 1-30 (Complete)"
            case .largeNumbers: return "Large Numbers"
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
            case .numbers0to10: return "零, 一, 二, 三, 四, 五, 六, 七, 八, 九, 十"
            case .numbers1to10: return "一, 二, 三, 四, 五, 六, 七, 八, 九, 十"
            case .numbers11to19: return "十一, 十二, 十三... 十九"
            case .numbers20to30: return "二十, 二十一, 二十二... 三十"
            case .numbers1to30: return "All numbers from 1 to 30"
            case .largeNumbers: return "十, 百, 千, 万, 億"
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
            case .numbers0to10, .numbers1to10: return "1.circle.fill"
            case .numbers11to19: return "11.circle.fill"
            case .numbers20to30: return "20.circle.fill"
            case .numbers1to30: return "30.circle.fill"
            case .largeNumbers: return "infinity.circle.fill"
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
            case .numbers0to10: return 11
            case .numbers1to10: return 10
            case .numbers11to19: return 9
            case .numbers20to30: return 11
            case .numbers1to30: return 30
            case .largeNumbers: return 5
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
        
        func createViewModel(env: AppEnvironment) -> SequentialPracticeViewModel {
            switch self {
            case .numbers0to10: return .chineseNumbers0to10(env: env)
            case .numbers1to10: return .chineseNumbers1to10(env: env)
            case .numbers11to19: return .chineseNumbers11to19(env: env)
            case .numbers20to30: return .chineseNumbers20to30(env: env)
            case .numbers1to30: return .chineseNumbers1to30(env: env)
            case .largeNumbers: return .chineseLargeNumbers(env: env)
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
                SequentialPracticeHelp.SetSelectorBanner(scriptName: "Chinese Characters")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section("Numbers") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.numbers0to10.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .numbers0to10)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.numbers1to10.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .numbers1to10)
                }
            }
            
            Section("Teen Numbers") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.numbers11to19.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .numbers11to19)
                }
            }
            
            Section("Twenties & Thirties") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.numbers20to30.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .numbers20to30)
                }
            }
            
            Section("Complete Number Sets") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.numbers1to30.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .numbers1to30)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.largeNumbers.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .largeNumbers)
                }
            }
            
            Section("Basic Characters") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.bodyParts.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .bodyParts)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.nature.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .nature)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.sizeDirection.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .sizeDirection)
                }
            }
            
            Section("Daily Life") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.objects.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .objects)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.pronouns.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .pronouns)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.verbs.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .verbs)
                }
                
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.commonWords.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .commonWords)
                }
            }
            
            Section("Master Set") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.all100.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .all100)
                }
            }
        }
        .navigationTitle("Chinese Sequential Practice")
    }
}

/// Row view for a number set option
struct NumberSetRow: View {
    let set: ChineseNumberSetSelector.NumberSet
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: set.icon)
                .font(.title2)
                .foregroundStyle(.blue)
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
            ChineseNumberSetSelector(env: AppEnvironment(
                glyphs: GlyphBundleRepository(),
                progress: SwiftDataProgressStore(),
                evaluator: DefaultAttemptEvaluator()
            ))
        }
    } else {
        // Fallback on earlier versions
    }
}

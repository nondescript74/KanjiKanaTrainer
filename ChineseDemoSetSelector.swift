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
        
        // First 100 Chinese Characters (Beginner Curriculum)
        case first100All = "first100all"
        case first100Greetings = "first100greet"
        case first100Introduction = "first100intro"
        case first100Family = "first100family"
        case numbers11to19 = "11-19"
        case numbers20to30 = "20-30"
        case tensTo100 = "tens"
        case numbers31to40 = "31-40"
        case numbers41to50 = "41-50"
        case numbers51to60 = "51-60"
        case numbers61to70 = "61-70"
        case numbers71to80 = "71-80"
        case numbers81to90 = "81-90"
        case numbers91to100 = "91-100"
        case familyRelatives = "familyrelatives"
        case first100Time = "first100time"
        case first100School = "first100school"
        case first100Food = "first100food"
        
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
            // First 100
            case .first100All: return "First 100 Characters (Complete)"
            case .first100Greetings: return "Greetings & Politeness"
            case .first100Introduction: return "Self-Introduction"
            case .first100Family: return "Family Members"
            case .numbers11to19: return "Numbers 11-19"
            case .numbers20to30: return "Numbers 20-30"
            case .tensTo100: return "Tens 10-100"
            case .numbers31to40: return "Numbers 31-40"
            case .numbers41to50: return "Numbers 41-50"
            case .numbers51to60: return "Numbers 51-60"
            case .numbers61to70: return "Numbers 61-70"
            case .numbers71to80: return "Numbers 71-80"
            case .numbers81to90: return "Numbers 81-90"
            case .numbers91to100: return "Numbers 91-100"
            case .familyRelatives: return "Grandparents & Relatives"
            case .first100Time: return "Time Expressions"
            case .first100School: return "School & Learning"
            case .first100Food: return "Food & Meals"
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
            // First 100
            case .first100All: return "Complete beginner set of 99 essential characters"
            case .first100Greetings: return "好, 请, 谢, 再见, 问"
            case .first100Introduction: return "我, 叫, 名字, 他, 什么"
            case .first100Family: return "爸, 妈, 哥, 姐, 弟, 妹, 父, 母, 女, 儿, 子"
            case .numbers11to19: return "十一, 十二, 十三... 十九"
            case .numbers20to30: return "二十, 二十一, 二十二... 三十"
            case .tensTo100: return "十, 二十, 三十... 一百"
            case .numbers31to40: return "三十一, 三十二... 四十"
            case .numbers41to50: return "四十一, 四十二... 五十"
            case .numbers51to60: return "五十一, 五十二... 六十"
            case .numbers61to70: return "六十一, 六十二... 七十"
            case .numbers71to80: return "七十一, 七十二... 八十"
            case .numbers81to90: return "八十一, 八十二... 九十"
            case .numbers91to100: return "九十一, 九十二... 一百"
            case .familyRelatives: return "爷, 奶, 外公, 外婆, 叔, 姨, 舅, 姑"
            case .first100Time: return "今天, 明天, 星期, 上午, 下午"
            case .first100School: return "大学, 小学, 学校, 老师, 同学"
            case .first100Food: return "吃, 喝, 饭, 晚饭"
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
            // First 100
            case .first100All: return "star.circle.fill"
            case .first100Greetings: return "hand.wave.fill"
            case .first100Introduction: return "person.badge.plus"
            case .first100Family: return "person.3.fill"
            case .numbers11to19: return "11.circle.fill"
            case .numbers20to30: return "20.circle.fill"
            case .tensTo100: return "number.circle.fill"
            case .numbers31to40: return "number.circle"
            case .numbers41to50: return "number.circle"
            case .numbers51to60: return "number.circle"
            case .numbers61to70: return "number.circle"
            case .numbers71to80: return "number.circle"
            case .numbers81to90: return "number.circle"
            case .numbers91to100: return "number.circle"
            case .familyRelatives: return "figure.2.and.child.holdinghands"
            case .first100Time: return "clock.fill"
            case .first100School: return "building.2.fill"
            case .first100Food: return "fork.knife"
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
            // First 100
            case .first100All: return 99
            case .first100Greetings: return 6
            case .first100Introduction: return 7
            case .first100Family: return 11
            case .numbers11to19: return 9
            case .numbers20to30: return 11
            case .tensTo100: return 10
            case .numbers31to40: return 10
            case .numbers41to50: return 10
            case .numbers51to60: return 10
            case .numbers61to70: return 10
            case .numbers71to80: return 10
            case .numbers81to90: return 10
            case .numbers91to100: return 10
            case .familyRelatives: return 9
            case .first100Time: return 11
            case .first100School: return 9
            case .first100Food: return 4
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
            // First 100
            case .first100All: return .firstHundredChinese(env: env)
            case .first100Greetings: return .firstHundredGreetings(env: env)
            case .first100Introduction: return .firstHundredIntroduction(env: env)
            case .first100Family: return .firstHundredFamily(env: env)
            case .numbers11to19: return .chineseNumbers(Array(11...19), env: env)
            case .numbers20to30: return .chineseNumbers(Array(20...30), env: env)
            case .tensTo100: return .chineseNumbers(Array(stride(from: 10, through: 100, by: 10)), env: env)
            case .numbers31to40: return .chineseNumbers(Array(31...40), env: env)
            case .numbers41to50: return .chineseNumbers(Array(41...50), env: env)
            case .numbers51to60: return .chineseNumbers(Array(51...60), env: env)
            case .numbers61to70: return .chineseNumbers(Array(61...70), env: env)
            case .numbers71to80: return .chineseNumbers(Array(71...80), env: env)
            case .numbers81to90: return .chineseNumbers(Array(81...90), env: env)
            case .numbers91to100: return .chineseNumbers(Array(91...100), env: env)
            case .familyRelatives: return .familyRelatives(env: env)
            case .first100Time: return .firstHundredTime(env: env)
            case .first100School: return .firstHundredSchool(env: env)
            case .first100Food: return .firstHundredFood(env: env)
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
            
            Section("Numbers to 100") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers11to19.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers11to19)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers20to30.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers20to30)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.tensTo100.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .tensTo100)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers31to40.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers31to40)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers41to50.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers41to50)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers51to60.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers51to60)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers61to70.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers61to70)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers71to80.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers71to80)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers81to90.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers81to90)
                }

                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers91to100.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers91to100)
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
            
            Section("First 100 Beginner Characters") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.first100All.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .first100All)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.first100Greetings.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .first100Greetings)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.first100Introduction.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .first100Introduction)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.first100Family.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .first100Family)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.familyRelatives.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .familyRelatives)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.first100Time.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .first100Time)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.first100School.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .first100School)
                }
                
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.first100Food.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .first100Food)
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

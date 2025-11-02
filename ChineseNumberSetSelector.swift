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
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .numbers0to10: return "Numbers 0-10"
            case .numbers1to10: return "Numbers 1-10"
            case .numbers11to19: return "Numbers 11-19"
            case .numbers20to30: return "Numbers 20-30"
            case .numbers1to30: return "Numbers 1-30 (Complete)"
            case .largeNumbers: return "Large Numbers"
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
            }
        }
        
        var icon: String {
            switch self {
            case .numbers0to10, .numbers1to10: return "1.circle.fill"
            case .numbers11to19: return "11.circle.fill"
            case .numbers20to30: return "20.circle.fill"
            case .numbers1to30: return "30.circle.fill"
            case .largeNumbers: return "infinity.circle.fill"
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
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                SequentialPracticeHelp.SetSelectorBanner()
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section("Basic Numbers") {
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
            
            Section("Complete Sets") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.numbers1to30.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .numbers1to30)
                }
            }
            
            Section("Large Numbers") {
                NavigationLink {
                    SequentialPracticeView(viewModel: NumberSet.largeNumbers.createViewModel(env: env))
                } label: {
                    NumberSetRow(set: .largeNumbers)
                }
            }
        }
        .navigationTitle("Sequential Practice")
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

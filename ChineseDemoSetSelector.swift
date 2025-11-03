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
        
        var id: String { rawValue }
        
        var title: String {
            "Numbers 1-10"
        }
        
        var description: String {
            "一, 二, 三, 四, 五, 六, 七, 八, 九, 十"
        }
        
        var icon: String {
            "play.circle.fill"
        }
        
        var characterCount: Int {
            10
        }
        
        func createViewModel(env: AppEnvironment) -> SequentialDemoViewModel {
            .chineseNumbers1to10(env: env)
        }
    }
    
    var body: some View {
        List {
            Section {
                DemoHelpBanner(scriptName: "Chinese Numbers")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section("Basic Numbers") {
                NavigationLink {
                    SequentialDemoView(viewModel: DemoSet.numbers1to10.createViewModel(env: env))
                } label: {
                    ChineseDemoSetRow(set: .numbers1to10)
                }
            }
        }
        .navigationTitle("Chinese Number Demos")
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

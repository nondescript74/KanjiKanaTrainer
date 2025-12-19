//
//  AudioIntegrationExample.swift
//  KanjiKanaTrainer
//
//  Created by Assistant on 12/19/25.
//
//  This file demonstrates how to integrate audio buttons into your views
//

import SwiftUI

// MARK: - Example 1: Adding to Demo View Toolbar

/*
 In your SequentialDemoView or similar view, add this to the toolbar:
 
 .toolbar {
     ToolbarItemGroup(placement: .bottomBar) {
         // Previous button
         Button(action: {
             viewModel.previousGlyph()
         }) {
             Image(systemName: "chevron.left")
         }
         .disabled(!viewModel.hasPrevious)
         
         Spacer()
         
         // AUDIO BUTTON (NEW!)
         AudioButton(action: {
             viewModel.playCurrentPronunciation()
         }, style: .standard)
         
         Spacer()
         
         // Next button
         Button(action: {
             viewModel.nextGlyph()
         }) {
             Image(systemName: "chevron.right")
         }
         .disabled(!viewModel.hasNext)
     }
 }
*/

// MARK: - Example 2: Adding Dual Language Buttons to Content Area

struct DemoViewWithAudio: View {
    @ObservedObject var viewModel: SequentialDemoViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Character display
            if let glyph = viewModel.currentGlyph {
                Text(glyph.literal)
                    .font(.system(size: 120))
                
                Text(glyph.readings.first ?? "")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                // DUAL AUDIO BUTTONS (NEW!)
                DualAudioButtons(
                    onPlayMandarin: {
                        viewModel.playCurrentPronunciation()
                    },
                    onPlayCantonese: {
                        viewModel.playCurrentCantonese()
                    },
                    isPlaying: viewModel.demoState == .drawing
                )
                .padding()
            }
            
            // Demo controls
            HStack {
                Button("Previous") {
                    viewModel.previousGlyph()
                }
                .disabled(!viewModel.hasPrevious)
                
                Spacer()
                
                Button(viewModel.demoState == .drawing ? "Stop" : "Start") {
                    if viewModel.demoState == .drawing {
                        viewModel.stopDemo()
                    } else {
                        viewModel.startDemo()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button("Next") {
                    viewModel.nextGlyph()
                }
                .disabled(!viewModel.hasNext)
            }
            .padding()
        }
    }
}

// MARK: - Example 3: Adding to Practice View

struct PracticeViewWithAudio: View {
    @ObservedObject var viewModel: SequentialPracticeViewModel
    
    var body: some View {
        VStack {
            // Drawing canvas
            // ... your canvas view ...
            
            // Character info with audio
            if let glyph = viewModel.currentGlyph {
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Character: \(glyph.literal)")
                            .font(.title3)
                        
                        Text("Pinyin: \(glyph.readings.first ?? "")")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // AUDIO BUTTON (NEW!)
                    AudioButton(action: {
                        glyph.playPronunciation()
                    }, style: .compact)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Example 4: Simple Button in Any View

struct SimpleAudioExample: View {
    let character: CharacterGlyph
    
    var body: some View {
        HStack {
            Text(character.literal)
                .font(.largeTitle)
            
            // SIMPLEST INTEGRATION
            Button(action: {
                character.playPronunciation()
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
    }
}

// MARK: - Example 5: Character Card with Audio

struct CharacterCard: View {
    let glyph: CharacterGlyph
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Character
            Text(glyph.literal)
                .font(.system(size: 100))
            
            // Pronunciation
            Text(glyph.readings.first ?? "")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            // Meaning
            Text(glyph.meaning.joined(separator: ", "))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // Audio buttons
            HStack(spacing: 12) {
                Button(action: {
                    glyph.playPronunciation()
                    isPlaying = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isPlaying = false
                    }
                }) {
                    Label("Mandarin", systemImage: "speaker.wave.2.fill")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .cornerRadius(8)
                }
                
                if glyph.readings.count >= 2 {
                    Button(action: {
                        glyph.playCantonesePromunication()
                        isPlaying = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isPlaying = false
                        }
                    }) {
                        Label("Cantonese", systemImage: "speaker.wave.2.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .foregroundStyle(.orange)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Example 6: Auto-play Toggle

struct DemoViewWithAutoAudio: View {
    @ObservedObject var viewModel: SequentialDemoViewModel
    @State private var autoPlayAudio = true
    
    var body: some View {
        VStack {
            // Your demo content...
            
            Toggle("Auto-play pronunciation", isOn: $autoPlayAudio)
                .padding()
            
            // When demo completes, optionally play audio
            // (This is already handled in SequentialDemoViewModel)
        }
        .onChange(of: viewModel.demoState) { oldValue, newValue in
            if newValue == .completed && autoPlayAudio {
                viewModel.playCurrentPronunciation()
            }
        }
    }
}

// MARK: - Previews

#Preview("Character Card") {
    CharacterCard(glyph: CharacterGlyph(
        script: .hanzi,
        codepoint: 0x597D,
        literal: "好",
        readings: ["hǎo", "hou2"],
        meaning: ["good", "well"],
        strokes: [],
        difficulty: 1,
        components: nil
    ))
    .padding()
}

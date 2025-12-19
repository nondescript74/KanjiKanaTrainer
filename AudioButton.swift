//
//  AudioButton.swift
//  KanjiKanaTrainer
//
//  Created by Assistant on 12/19/25.
//

import SwiftUI

/// A button that plays audio pronunciation for a character
struct AudioButton: View {
    let action: () -> Void
    let style: AudioButtonStyle
    let isPlaying: Bool
    
    init(
        action: @escaping () -> Void,
        style: AudioButtonStyle = .standard,
        isPlaying: Bool = false
    ) {
        self.action = action
        self.style = style
        self.isPlaying = isPlaying
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: style.spacing) {
                Image(systemName: isPlaying ? "speaker.wave.3.fill" : style.icon)
                    .font(style.font)
                    .foregroundStyle(style.color)
                
                if let label = style.label {
                    Text(label)
                        .font(style.textFont)
                        .foregroundStyle(style.color)
                }
            }
            .padding(style.padding)
            .background(style.background)
            .cornerRadius(style.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

/// Style configurations for audio buttons
struct AudioButtonStyle {
    let icon: String
    let font: Font
    let color: Color
    let label: String?
    let textFont: Font
    let padding: EdgeInsets
    let background: Color
    let cornerRadius: CGFloat
    let spacing: CGFloat
    
    /// Standard audio button (icon only)
    static let standard = AudioButtonStyle(
        icon: "speaker.wave.2.fill",
        font: .title2,
        color: .blue,
        label: nil,
        textFont: .body,
        padding: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8),
        background: .clear,
        cornerRadius: 8,
        spacing: 8
    )
    
    /// Compact audio button (smaller icon)
    static let compact = AudioButtonStyle(
        icon: "speaker.wave.2.fill",
        font: .body,
        color: .blue,
        label: nil,
        textFont: .caption,
        padding: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4),
        background: .clear,
        cornerRadius: 6,
        spacing: 4
    )
    
    /// Large audio button with label
    static let large = AudioButtonStyle(
        icon: "speaker.wave.2.fill",
        font: .title,
        color: .blue,
        label: "Play Sound",
        textFont: .headline,
        padding: EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16),
        background: Color.blue.opacity(0.1),
        cornerRadius: 12,
        spacing: 12
    )
    
    /// Mandarin pronunciation button
    static let mandarin = AudioButtonStyle(
        icon: "speaker.wave.2.fill",
        font: .body,
        color: .blue,
        label: "普通话",
        textFont: .caption,
        padding: EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10),
        background: Color.blue.opacity(0.1),
        cornerRadius: 8,
        spacing: 6
    )
    
    /// Cantonese pronunciation button
    static let cantonese = AudioButtonStyle(
        icon: "speaker.wave.2.fill",
        font: .body,
        color: .orange,
        label: "粤语",
        textFont: .caption,
        padding: EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10),
        background: Color.orange.opacity(0.1),
        cornerRadius: 8,
        spacing: 6
    )
}

/// A view that shows both Mandarin and Cantonese audio buttons
struct DualAudioButtons: View {
    let onPlayMandarin: () -> Void
    let onPlayCantonese: () -> Void
    let isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            AudioButton(
                action: onPlayMandarin,
                style: .mandarin,
                isPlaying: isPlaying
            )
            
            AudioButton(
                action: onPlayCantonese,
                style: .cantonese,
                isPlaying: isPlaying
            )
        }
    }
}

// MARK: - Preview

#Preview("Standard Button") {
    VStack(spacing: 20) {
        AudioButton(action: {}, style: .standard)
        AudioButton(action: {}, style: .compact)
        AudioButton(action: {}, style: .large)
        AudioButton(action: {}, style: .mandarin)
        AudioButton(action: {}, style: .cantonese)
        
        DualAudioButtons(
            onPlayMandarin: {},
            onPlayCantonese: {},
            isPlaying: false
        )
    }
    .padding()
}

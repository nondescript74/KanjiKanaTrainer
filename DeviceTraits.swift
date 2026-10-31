//
//  DeviceTraits.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 10/22/25.
//

import SwiftUI

extension View {
    /// Returns appropriate canvas dimensions based on device type
    var adaptiveCanvasSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 500 : 300
    }
    
    /// Returns appropriate font size for the character display based on device type
    var adaptiveCharacterFontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 120 : 72
    }
}

/// A square that takes all the space its container leaves over and stays square, so a canvas
/// fits any device and orientation without fixed sizes. `reserve` is room kept below the
/// square inside the same space (for a status line under a canvas).
struct FillSquare<Content: View>: View {
    var reserve: CGFloat = 0
    @ViewBuilder var content: (CGFloat) -> Content

    var body: some View {
        GeometryReader { geometry in
            let side = max(0, min(geometry.size.width, geometry.size.height - reserve))
            content(side)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// Speaker button that says a character aloud (Mandarin for hanzi, Japanese for kana).
struct SpeakCharacterButton: View {
    let glyph: CharacterGlyph

    var body: some View {
        AudioButton(action: { glyph.playPronunciation() }, style: Self.style)
            .accessibilityLabel("Say it")
    }

    /// Icon only (fits the landscape column), big enough for a child's finger.
    static let style = AudioButtonStyle(
        icon: "speaker.wave.2.fill",
        font: .title,
        color: .blue,
        label: nil,
        textFont: .headline,
        padding: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
        background: Color.blue.opacity(0.1),
        cornerRadius: 12,
        spacing: 0
    )
}

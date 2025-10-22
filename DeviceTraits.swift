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

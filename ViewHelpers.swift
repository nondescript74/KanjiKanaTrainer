//
//  ViewHelpers.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/2/25.
//

import SwiftUI
import PencilKit

/// Adaptive font size for displaying characters based on device
let adaptiveCharacterFontSize: CGFloat = {
    #if os(iOS)
    return UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80
    #else
    return 80
    #endif
}()

/// Adaptive canvas size based on device
let adaptiveCanvasSize: CGFloat = {
    #if os(iOS)
    return UIDevice.current.userInterfaceIdiom == .pad ? 500 : 300
    #else
    return 300
    #endif
}()

///// UIViewRepresentable wrapper for PKCanvasView
//struct CanvasRepresentable: UIViewRepresentable {
//    @Binding var drawing: PKDrawing
//    
//    func makeUIView(context: Context) -> PKCanvasView {
//        let canvasView = PKCanvasView()
//        canvasView.drawing = drawing
//        canvasView.drawingPolicy = .anyInput
//        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
//        canvasView.delegate = context.coordinator
//        return canvasView
//    }
//    
//    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
//        canvasView.drawing = drawing
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, PKCanvasViewDelegate {
//        let parent: CanvasRepresentable
//        
//        init(_ parent: CanvasRepresentable) {
//            self.parent = parent
//        }
//        
//        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//            parent.drawing = canvasView.drawing
//        }
//    }
//}

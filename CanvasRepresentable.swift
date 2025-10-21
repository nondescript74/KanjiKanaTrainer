//
//  CanvasRepresentable.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 10/17/25.
//
//
//import Foundation
import SwiftUI
import PencilKit

struct CanvasRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        
        // Ensure canvas doesn't limit content size
        canvas.alwaysBounceVertical = false
        canvas.alwaysBounceHorizontal = false
        
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update canvas drawing when binding changes externally (like clear)
        if uiView.drawing != drawing {
            context.coordinator.isUpdatingFromSwiftUI = true
            uiView.drawing = drawing
            context.coordinator.isUpdatingFromSwiftUI = false
        }
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var isUpdatingFromSwiftUI = false
        
        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Only sync user drawings back to SwiftUI, not programmatic changes
            guard !isUpdatingFromSwiftUI else { return }
            
            // Use Task to avoid modifying state during view update
            Task { @MainActor in
                drawing = canvasView.drawing
            }
        }
    }
}

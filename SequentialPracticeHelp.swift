//
//  SequentialPracticeHelp.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/2/25.
//

import SwiftUI

/// Contextual help components for Sequential Practice features
struct SequentialPracticeHelp {
    
    /// Help banner for the number set selector
    struct SetSelectorBanner: View {
        let scriptName: String
        @AppStorage("hasSeenSequentialPracticeHelp") private var hasSeenHelp = false
        @State private var isExpanded = false
        
        init(scriptName: String = "Chinese Numbers") {
            self.scriptName = scriptName
        }
        
        var body: some View {
            if !hasSeenHelp || isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("Sequential Practice - \(scriptName)")
                            .font(.headline)
                        Spacer()
                        Button {
                            withAnimation {
                                if !hasSeenHelp {
                                    hasSeenHelp = true
                                }
                                isExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    if !hasSeenHelp || isExpanded {
                        VStack(alignment: .leading, spacing: 6) {
                            HelpRow(icon: "arrow.right.circle", text: "Practice characters in order, one at a time")
                            HelpRow(icon: "chart.bar", text: "Numbers show how many characters in each set")
                            HelpRow(icon: "graduationcap", text: "Start with smaller sets, progress to larger ones")
                        }
                        .padding(.top, 4)
                        
                        if !hasSeenHelp {
                            Button {
                                withAnimation {
                                    hasSeenHelp = true
                                }
                            } label: {
                                Text("Got it!")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                // Compact help button
                Button {
                    withAnimation {
                        isExpanded = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Show Help")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// Help row with icon and text
    struct HelpRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    /// First-time overlay for the practice view
    struct PracticeOverlay: View {
        @AppStorage("hasSeenPracticeHelp") private var hasSeenHelp = false
        @Binding var isPresented: Bool
        
        var body: some View {
            if isPresented {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("How to Practice")
                            .font(.title2)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TutorialStep(number: 1, text: "Draw the character on the canvas")
                            TutorialStep(number: 2, text: "Tap 'Evaluate' to check your drawing")
                            TutorialStep(number: 3, text: "Use 'Next' to move to the next character")
                            TutorialStep(number: 4, text: "Use 'Previous' to review earlier ones")
                        }
                        .padding()
                        
                        Text("Tip: Stroke order and direction matter!")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.horizontal)
                        
                        Button {
                            withAnimation {
                                hasSeenHelp = true
                                isPresented = false
                            }
                        } label: {
                            Text("Start Practicing")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .padding(40)
                }
            }
        }
    }
    
    /// Tutorial step view
    struct TutorialStep: View {
        let number: Int
        let text: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Text("\(number)")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.blue))
                
                Text(text)
                    .font(.subheadline)
            }
        }
    }
    
    /// Inline tip view that can be shown temporarily
    struct InlineTip: View {
        let icon: String
        let message: String
        let color: Color
        @Binding var isVisible: Bool
        
        init(icon: String, message: String, color: Color = .blue, isVisible: Binding<Bool>) {
            self.icon = icon
            self.message = message
            self.color = color
            self._isVisible = isVisible
        }
        
        var body: some View {
            if isVisible {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        withAnimation {
                            isVisible = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(color.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    /// Tooltip modifier for buttons
    struct TooltipModifier: ViewModifier {
        let text: String
        @State private var showTooltip = false
        
        func body(content: Content) -> some View {
            content
                .overlay(alignment: .top) {
                    if showTooltip {
                        Text(text)
                            .font(.caption2)
                            .padding(6)
                            .background(Color.black.opacity(0.8))
                            .foregroundStyle(.white)
                            .cornerRadius(6)
                            .offset(y: -40)
                            .transition(.opacity)
                    }
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    withAnimation {
                        showTooltip = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showTooltip = false
                        }
                    }
                }
        }
    }
}

// View extension for easy tooltip access
extension View {
    func practiceTooltip(_ text: String) -> some View {
        self.modifier(SequentialPracticeHelp.TooltipModifier(text: text))
    }
}

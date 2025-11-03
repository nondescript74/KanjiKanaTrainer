//
//  SequentialDemoHelp.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// Comprehensive help system for Sequential Demo features
struct SequentialDemoHelp: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // What is Sequential Demo
                    whatIsSection
                    
                    // How to Use
                    howToUseSection
                    
                    // Features
                    featuresSection
                    
                    // Tips
                    tipsSection
                }
                .padding()
            }
            .navigationTitle("Sequential Demo Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Sequential Demo Mode")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Watch stroke-by-stroke demonstrations of characters in organized sets")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var whatIsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "questionmark.circle.fill", title: "What is Sequential Demo?")
            
            Text("Sequential Demo allows you to watch animated demonstrations of how to write characters, shown one after another in a specific order. Perfect for:")
                .font(.body)
            
            BulletPoint(text: "Learning proper stroke order")
            BulletPoint(text: "Understanding stroke direction")
            BulletPoint(text: "Seeing how characters are constructed")
            BulletPoint(text: "Reviewing multiple characters in sequence")
        }
    }
    
    private var howToUseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "hand.tap.fill", title: "How to Use")
            
            StepCard(
                number: 1,
                title: "Select a Set",
                description: "Choose a character set from the main menu (vowels, rows, numbers, etc.)"
            )
            
            StepCard(
                number: 2,
                title: "Tap Play",
                description: "Watch as the character is drawn stroke-by-stroke with proper order and direction"
            )
            
            StepCard(
                number: 3,
                title: "Navigate",
                description: "Use Previous/Next buttons to move through the sequence at your own pace"
            )
            
            StepCard(
                number: 4,
                title: "Replay Anytime",
                description: "Tap Replay to watch the demonstration again"
            )
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "star.fill", title: "Features")
            
            FeatureRow(
                icon: "play.fill",
                title: "Play/Replay",
                description: "Start or replay the demonstration for the current character"
            )
            
            FeatureRow(
                icon: "stop.fill",
                title: "Stop",
                description: "Stop the animation at any time"
            )
            
            FeatureRow(
                icon: "repeat.circle.fill",
                title: "Auto-Play",
                description: "Automatically advance to the next character after each demo completes"
            )
            
            FeatureRow(
                icon: "speaker.wave.2.fill",
                title: "Audio Pronunciation",
                description: "Hear the correct pronunciation after each demonstration"
            )
            
            FeatureRow(
                icon: "chart.bar.fill",
                title: "Progress Tracking",
                description: "See your position in the sequence with a visual progress bar"
            )
            
            FeatureRow(
                icon: "arrow.left.arrow.right",
                title: "Navigation",
                description: "Jump to previous or next characters freely"
            )
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "lightbulb.fill", title: "Tips for Learning", color: .orange)
            
            TipCard(
                icon: "eye.fill",
                title: "Watch Carefully",
                description: "Pay attention to the starting point and direction of each stroke",
                color: .blue
            )
            
            TipCard(
                icon: "arrow.counterclockwise",
                title: "Replay Multiple Times",
                description: "Don't hesitate to replay demonstrations until you understand the stroke order",
                color: .green
            )
            
            TipCard(
                icon: "repeat.circle.fill",
                title: "Use Auto-Play",
                description: "Enable auto-play to watch multiple characters without manual navigation",
                color: .purple
            )
            
            TipCard(
                icon: "pencil.and.outline",
                title: "Practice After Watching",
                description: "After watching a demo, try writing the character yourself in Practice mode",
                color: .orange
            )
            
            TipCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Start Small",
                description: "Begin with smaller sets (like vowels) before moving to complete sets",
                color: .pink
            )
        }
    }
}

// MARK: - Component Views

struct SectionHeader: View {
    let icon: String
    let title: String
    var color: Color = .blue
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
                .foregroundStyle(.blue)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.leading, 8)
    }
}

struct StepCard: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            Text("\(number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.blue))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview {
    SequentialDemoHelp()
}

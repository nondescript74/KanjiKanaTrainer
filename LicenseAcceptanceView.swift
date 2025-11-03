//
//  LicenseAcceptanceView.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// A view that presents the software license agreement and requires user acceptance
struct LicenseAcceptanceView: View {
    @StateObject private var viewModel = LicenseAcceptanceViewModel()
    @Environment(\.dismiss) private var dismiss
    
    /// Callback when license is accepted
    let onAccept: () -> Void
    
    /// Callback when user declines (optional - for custom handling)
    let onDecline: (() -> Void)?
    
    @State private var showDeclineAlert = false
    @State private var contentHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    init(onAccept: @escaping () -> Void, onDecline: (() -> Void)? = nil) {
        self.onAccept = onAccept
        self.onDecline = onDecline
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // License text with scroll tracking
                GeometryReader { outerGeometry in
                    ScrollView {
                        Text(viewModel.licenseText)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(
                                GeometryReader { textGeometry in
                                    Color.clear.preference(
                                        key: ContentHeightPreferenceKey.self,
                                        value: textGeometry.size.height
                                    )
                                }
                            )
                            .background(
                                GeometryReader { contentGeometry in
                                    Color.clear.preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: contentGeometry.frame(in: .named("scrollView")).minY
                                    )
                                }
                            )
                    }
                    .coordinateSpace(name: "scrollView")
                    .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                        contentHeight = height
                    }
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        scrollOffset = offset
                        updateScrollProgress(
                            contentHeight: contentHeight,
                            viewportHeight: outerGeometry.size.height,
                            offset: offset
                        )
                    }
                }
                .background(Color(UIColor.systemBackground))
                
                // Scroll indicator
                if !viewModel.hasScrolledToBottom {
                    scrollIndicator
                }
                
                // Agreement checkbox and buttons
                agreementSection
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("License Agreement")
                        .font(.headline)
                }
                
                #if DEBUG
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.hasScrolledToBottom = true
                            viewModel.scrollProgress = 1.0
                        } label: {
                            Label("Skip Scroll Requirement", systemImage: "forward.fill")
                        }
                        
                        Button {
                            viewModel.hasScrolledToBottom = true
                            viewModel.hasAgreed = true
                            viewModel.scrollProgress = 1.0
                        } label: {
                            Label("Auto-Accept (Test)", systemImage: "checkmark.circle.fill")
                        }
                        
                        Button(role: .destructive) {
                            viewModel.resetAcceptance()
                        } label: {
                            Label("Reset Acceptance", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(.orange)
                    }
                }
                #endif
            }
            .alert("Decline License", isPresented: $showDeclineAlert) {
                Button("Review Again", role: .cancel) { }
                Button("Exit App", role: .destructive) {
                    if let onDecline = onDecline {
                        onDecline()
                    } else {
                        // Default behavior: exit app
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }
                }
            } message: {
                Text("You must accept the license agreement to use this application. If you decline, the app will exit.")
            }
        }
        .interactiveDismissDisabled()
    }
    
    // MARK: - Helper Methods
    
    private func updateScrollProgress(contentHeight: CGFloat, viewportHeight: CGFloat, offset: CGFloat) {
        guard contentHeight > 0 else { return }
        
        // Calculate how much we can scroll
        let scrollableDistance = max(contentHeight - viewportHeight, 1)
        
        // Current scroll position (offset is negative when scrolling down)
        let currentScroll = -offset
        
        // Calculate progress (0.0 = top, 1.0 = bottom)
        let progress = min(max(currentScroll / scrollableDistance, 0), 1)
        
        viewModel.updateScrollProgress(progress)
        
        // Debug logging
        #if DEBUG
        if progress > viewModel.scrollProgress + 0.1 || progress < viewModel.scrollProgress - 0.1 {
            print("📜 Scroll Progress: \(Int(progress * 100))% | Content: \(Int(contentHeight)) | Viewport: \(Int(viewportHeight)) | Offset: \(Int(offset))")
        }
        #endif
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // App icon or logo
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
                .padding(.top)
            
            Text("Welcome to KanjiKana Trainer")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please read and accept the license agreement to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.bottom)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var scrollIndicator: some View {
        HStack {
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.blue)
            Text("Please scroll to read the entire agreement")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.yellow.opacity(0.2))
        .transition(.opacity)
    }
    
    private var agreementSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            // Progress indicator (only show before scrolled to bottom)
            if !viewModel.hasScrolledToBottom {
                HStack {
                    Text("Reading Progress:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * viewModel.scrollProgress)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(viewModel.scrollProgress * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
                .padding(.horizontal)
            }
            
            // Checkbox
            Button {
                withAnimation {
                    viewModel.hasAgreed.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.hasAgreed ? "checkmark.square.fill" : "square")
                        .font(.title2)
                        .foregroundStyle(viewModel.hasAgreed ? .blue : .gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("I have read and agree to the license terms")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        if !viewModel.hasScrolledToBottom {
                            Text("Read the entire agreement to enable this option")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
            .disabled(!viewModel.hasScrolledToBottom)
            .padding(.horizontal)
            
            // Action buttons
            HStack(spacing: 12) {
                Button {
                    showDeclineAlert = true
                } label: {
                    Text("Decline")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                }
                
                Button {
                    withAnimation {
                        viewModel.acceptLicense()
                        onAccept()
                    }
                } label: {
                    HStack {
                        Text("Accept & Continue")
                            .font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.canAccept ? Color.blue : Color.gray)
                    )
                }
                .disabled(!viewModel.canAccept)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - Preference Keys for Scroll Tracking

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    LicenseAcceptanceView(
        onAccept: {
            print("License accepted")
        },
        onDecline: {
            print("License declined")
        }
    )
}

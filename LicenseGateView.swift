//
//  LicenseGateView.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// A container view that shows the license acceptance screen if needed,
/// or the main content if the license has been accepted
struct LicenseGateView<Content: View>: View {
    @StateObject private var viewModel = LicenseAcceptanceViewModel()
    @State private var hasAcceptedLicense = false
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if viewModel.needsLicenseAcceptance && !hasAcceptedLicense {
                LicenseAcceptanceView(
                    onAccept: {
                        withAnimation {
                            hasAcceptedLicense = true
                        }
                    },
                    onDecline: {
                        // Exit the app
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }
                )
                .transition(.opacity)
            } else {
                content
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LicenseGateView {
        NavigationView {
            Text("Main App Content")
                .navigationTitle("App")
        }
    }
}

//
//  SettingsView.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI

/// Settings and About view for the application
struct SettingsView: View {
    @StateObject private var licenseViewModel = LicenseAcceptanceViewModel()
    @State private var showFullLicense = false
    
    var body: some View {
        List {
            // About Section
            Section {
                HStack {
                    Image(systemName: "app.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("KanjiKana Trainer")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if let version = versionAndBuildNumber() {
                            Text(version)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Educational Writing Practice")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Copyright Section
            Section("Copyright") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("© 2025 Zahirudeen Premji")
                        .font(.subheadline)
                    
                    Text("All rights reserved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            // License Section
            Section("License") {
                Button {
                    showFullLicense = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("View Full License")
                                .foregroundStyle(.primary)
                            Text("Creative Commons Attribution 4.0")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.blue)
                    }
                }
                
                if let dateString = licenseViewModel.acceptanceDateString {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("License Accepted")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(dateString)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Privacy Section
            Section("Privacy") {
                InfoRow(
                    icon: "lock.shield.fill",
                    title: "No Data Collection",
                    description: "This app does not collect or transmit any personal data"
                )
                
                InfoRow(
                    icon: "internaldrive.fill",
                    title: "Local Storage Only",
                    description: "All progress is stored locally on your device"
                )
                
                InfoRow(
                    icon: "eye.slash.fill",
                    title: "No Analytics",
                    description: "No tracking or usage analytics"
                )
                
                InfoRow(
                    icon: "megaphone.fill",
                    title: "No Advertisements",
                    description: "Ad-free experience"
                )
            }
            
            // Credits Section
            Section("Credits & Acknowledgments") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Special Thanks To:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text("• Open-source stroke data contributors")
                    Text("• KanjiVG project")
                    Text("• Educational resource creators")
                    Text("• Language learning community")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
            }
            
            // Support Section
            Section("Support") {
                InfoRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Documentation",
                    description: "Contextual help available throughout the app"
                )
                
                InfoRow(
                    icon: "graduationcap.fill",
                    title: "Educational Purpose",
                    description: "Designed for learning Japanese kana and Chinese numbers"
                )
            }
        }
        .navigationTitle("About & Settings")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showFullLicense) {
            NavigationView {
                ScrollView {
                    Text(licenseViewModel.licenseText)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                }
                .navigationTitle("Full License")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showFullLicense = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

/// A row showing an icon, title, and description
struct InfoRow: View {
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
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Helper function to get version and build number
func versionAndBuildNumber() -> String? {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "Version \(version) (\(build))"
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
}

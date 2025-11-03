//
//  LicenseAcceptanceViewModel.swift
//  KanjiKanaTrainer
//
//  Created by Zahirudeen Premji on 11/3/25.
//

import SwiftUI
import Combine

/// View model managing license acceptance state and logic
@MainActor
class LicenseAcceptanceViewModel: ObservableObject {
    
    // MARK: - Constants
    
    /// The current version of the license that requires acceptance
    static let currentLicenseVersion = "1.0"
    
    /// UserDefaults key for storing accepted license version
    private static let acceptedLicenseVersionKey = "acceptedLicenseVersion"
    
    /// UserDefaults key for storing acceptance date
    private static let licenseAcceptanceDateKey = "licenseAcceptanceDate"
    
    // MARK: - Published Properties
    
    /// Whether the user has scrolled to the bottom of the license
    @Published var hasScrolledToBottom = false
    
    /// Whether the user has checked the acceptance checkbox
    @Published var hasAgreed = false
    
    /// The scroll position (0.0 = top, 1.0 = bottom)
    @Published var scrollProgress: CGFloat = 0.0
    
    // MARK: - Computed Properties
    
    /// Whether the "Accept" button should be enabled
    var canAccept: Bool {
        hasScrolledToBottom && hasAgreed
    }
    
    /// Whether the user needs to see and accept the license
    var needsLicenseAcceptance: Bool {
        let acceptedVersion = UserDefaults.standard.string(forKey: Self.acceptedLicenseVersionKey)
        return acceptedVersion != Self.currentLicenseVersion
    }
    
    /// The date when the license was last accepted, if available
    var licenseAcceptanceDate: Date? {
        UserDefaults.standard.object(forKey: Self.licenseAcceptanceDateKey) as? Date
    }
    
    // MARK: - License Text
    
    /// The full license text to display
    let licenseText: String = """
    KanjiKana Trainer - Software License Agreement
    
    Version 1.0
    Effective Date: November 3, 2025
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    COPYRIGHT NOTICE
    
    Copyright © 2025 Zahirudeen Premji. All rights reserved.
    
    This software application ("KanjiKana Trainer") and all associated content, including but not limited to stroke data, fonts, graphics, documentation, and source code, are protected by copyright laws and international copyright treaties.
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    LICENSE GRANT
    
    This application is licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0) with additional terms as specified below.
    
    You are free to:
    
    • Use — Use this application for personal, educational, or commercial purposes
    • Study — Examine how the application works and learn from its implementation
    • Share — Redistribute the application in any medium or format
    • Adapt — Create derivative works based on this application
    
    Under the following terms:
    
    • Attribution — You must give appropriate credit to Zahirudeen Premji, provide a link to the license, and indicate if changes were made.
    
    • No Additional Restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    STROKE DATA & FONTS LICENSE
    
    The character stroke data, font data, and glyph information included in this application are licensed under the Creative Commons Attribution 2.0 License (CC BY 2.0).
    
    Original Source Credit:
    • Stroke order data derived from KanjiVG and other open-source projects
    • Chinese character data adapted from publicly available resources
    • Japanese kana data compiled from educational resources
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    PRIVACY & DATA COLLECTION
    
    Your Privacy Matters:
    
    • No Personal Data Collection — This application does not collect, store, or transmit any personal information or user data to external servers
    • Local Storage Only — All practice progress, scores, and preferences are stored locally on your device
    • No Analytics — No usage analytics, crash reports, or tracking mechanisms are implemented
    • No Ads — This application contains no advertisements or third-party tracking
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    DISCLAIMER OF WARRANTIES
    
    THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT.
    
    The software is provided for educational purposes. While every effort has been made to ensure the accuracy of character stroke data and educational content, the copyright holder makes no guarantees regarding:
    
    • The accuracy, completeness, or educational effectiveness of the content
    • The software's suitability for any particular purpose
    • The uninterrupted or error-free operation of the software
    • The correction of any defects or errors
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    LIMITATION OF LIABILITY
    
    IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    
    This limitation includes, but is not limited to:
    • Direct or indirect damages
    • Loss of data or device malfunction
    • Business interruption or loss of profits
    • Personal injury or property damage
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    EDUCATIONAL USE
    
    This application is designed primarily for educational purposes to help learners practice writing Japanese hiragana, katakana, and Chinese numbers.
    
    Educational Disclaimer:
    • This application is a supplementary learning tool and should not be the sole method of learning these writing systems
    • Formal instruction from qualified teachers is recommended for comprehensive language learning
    • The stroke order and character forms presented follow standard conventions but may have regional variations
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    TERMINATION
    
    This license is effective until terminated. Your rights under this license will terminate automatically without notice if you fail to comply with any of its terms.
    
    Upon termination:
    • You must cease all use of the application
    • You must destroy all copies of the application in your possession
    • Any derivative works created must also comply with license terms or be destroyed
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    CHANGES TO THIS LICENSE
    
    The copyright holder reserves the right to modify this license agreement at any time. Continued use of the application after changes constitutes acceptance of the modified terms.
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    CONTACT INFORMATION
    
    For questions, permissions, or attribution inquiries, please contact:
    
    Zahirudeen Premji
    Developer of KanjiKana Trainer
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    ACCEPTANCE
    
    BY INSTALLING, COPYING, OR OTHERWISE USING THIS SOFTWARE, YOU AGREE TO BE BOUND BY THE TERMS OF THIS LICENSE AGREEMENT.
    
    If you do not agree to these terms, you must not use the software.
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    FULL LICENSE TEXT
    
    The full text of the Creative Commons Attribution 4.0 International License can be found at:
    https://creativecommons.org/licenses/by/4.0/legalcode
    
    The full text of the Creative Commons Attribution 2.0 License can be found at:
    https://creativecommons.org/licenses/by/2.0/legalcode
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    ACKNOWLEDGMENTS
    
    This application was created with love for language learners worldwide. Special thanks to:
    
    • The open-source community for making educational resources freely available
    • Contributors to stroke order data and educational materials
    • All users who dedicate time to learning new writing systems
    
    Thank you for using KanjiKana Trainer! Happy Learning! 🎓
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    Last Updated: November 3, 2025
    """
    
    // MARK: - Methods
    
    /// Records that the user has accepted the license
    func acceptLicense() {
        UserDefaults.standard.set(Self.currentLicenseVersion, forKey: Self.acceptedLicenseVersionKey)
        UserDefaults.standard.set(Date(), forKey: Self.licenseAcceptanceDateKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Updates scroll progress and determines if user has reached the bottom
    /// - Parameter progress: The scroll position from 0.0 (top) to 1.0 (bottom)
    func updateScrollProgress(_ progress: CGFloat) {
        scrollProgress = progress
        
        // Consider "bottom" reached when scrolled past 95%
        if progress >= 0.95 && !hasScrolledToBottom {
            hasScrolledToBottom = true
        }
    }
    
    /// Resets the acceptance state (for testing purposes)
    func resetAcceptance() {
        UserDefaults.standard.removeObject(forKey: Self.acceptedLicenseVersionKey)
        UserDefaults.standard.removeObject(forKey: Self.licenseAcceptanceDateKey)
        UserDefaults.standard.synchronize()
        hasScrolledToBottom = false
        hasAgreed = false
        scrollProgress = 0.0
    }
    
    /// Gets a formatted string of when the license was accepted
    var acceptanceDateString: String? {
        guard let date = licenseAcceptanceDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

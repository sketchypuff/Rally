//
//  SettingsViewModel.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// ViewModel for Settings and App Configuration
/// Handles business logic for app settings and configuration
/// Follows MVVM pattern by separating view logic from data management
@Observable
final class SettingsViewModel {
    // MARK: - Dependencies
    private let dataManager: DataManager
    
    // MARK: - Published Properties
    var settings: Settings
    var isLoading = false
    var errorMessage: String?
    var showingExportOptions = false
    var showingResetConfirmation = false
    
    // MARK: - Computed Properties
    
    /// Get current default target points
    var defaultTargetPoints: Int {
        return settings.defaultTargetPoints
    }
    
    /// Get current default best of sets
    var defaultBestOfSets: Int {
        return settings.defaultBestOfSets
    }
    
    /// Get current deuce rule setting
    var enableDeuceRule: Bool {
        // Debug log: Accessing deuce rule enabled setting from Settings
        // Rule applied: Add debug logs & comments for easier debug & readability
        return settings.enableDeuceRule
    }
    
    /// Get total number of matches
    var totalMatches: Int {
        return dataManager.matches.count
    }
    
    /// Get total number of players
    var totalPlayers: Int {
        return dataManager.players.count
    }
    
    /// Get total number of teams
    var totalTeams: Int {
        return dataManager.teams.count
    }
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        self.settings = dataManager.settings
        print("🏗️ SettingsViewModel: Initializing with DataManager")
    }
    
    // MARK: - Settings Actions
    
    /// Update default target points
    func updateTargetPoints(_ points: Int) {
        print("⚙️ SettingsViewModel: Updating target points to \(points)")
        settings.defaultTargetPoints = points
        saveSettings()
    }
    
    /// Update default best of sets
    func updateBestOfSets(_ sets: Int) {
        print("⚙️ SettingsViewModel: Updating best of sets to \(sets)")
        settings.defaultBestOfSets = sets
        saveSettings()
    }
    
    /// Toggle deuce rule
    func toggleDeuceRule() {
        print("⚙️ SettingsViewModel: Toggling deuce rule to \(!settings.enableDeuceRule)")
        settings.enableDeuceRule.toggle()
        saveSettings()
    }
    
    /// Save settings to DataManager
    private func saveSettings() {
        dataManager.updateSettings(settings)
        print("💾 SettingsViewModel: Settings saved")
    }
    
    // MARK: - Export Actions
    
    /// Show export options
    func showExportOptions() {
        print("📤 SettingsViewModel: Showing export options")
        showingExportOptions = true
    }
    
    /// Hide export options
    func hideExportOptions() {
        print("❌ SettingsViewModel: Hiding export options")
        showingExportOptions = false
    }
    
    /// Export matches as CSV
    func exportMatchesAsCSV() {
        print("📤 SettingsViewModel: Exporting matches as CSV")
        // TODO: Implement CSV export
        errorMessage = "CSV export coming soon"
    }
    
    /// Export matches as JSON
    func exportMatchesAsJSON() {
        print("📤 SettingsViewModel: Exporting matches as JSON")
        // TODO: Implement JSON export
        errorMessage = "JSON export coming soon"
    }
    
    // MARK: - Reset Actions
    
    /// Show reset confirmation
    func showResetConfirmation() {
        print("⚠️ SettingsViewModel: Showing reset confirmation")
        showingResetConfirmation = true
    }
    
    /// Hide reset confirmation
    func hideResetConfirmation() {
        print("❌ SettingsViewModel: Hiding reset confirmation")
        showingResetConfirmation = false
    }
    
    /// Reset all data
    func resetAllData() {
        print("🧹 SettingsViewModel: Resetting all data")
        dataManager.clearAllData()
        settings = Settings.default
        hideResetConfirmation()
        print("✅ SettingsViewModel: All data reset")
    }
    
    // MARK: - Helper Methods
    
    /// Get app version
    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// Get build number
    func getBuildNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    /// Get total storage used (approximate)
    func getStorageUsed() -> String {
        // TODO: Calculate actual storage usage
        return "~\(totalMatches * 2) KB"
    }
    
    /// Check if app is in development mode
    func isDevelopmentMode() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}

// MARK: - Preview Support
extension SettingsViewModel {
    /// Create a preview instance with sample data
    static func preview() -> SettingsViewModel {
        let viewModel = SettingsViewModel()
        return viewModel
    }
}

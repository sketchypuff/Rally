//
//  MatchListViewModel.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// ViewModel for Match List functionality
/// Handles business logic for displaying and managing matches
/// Follows MVVM pattern by separating view logic from data management
@Observable
final class MatchListViewModel {
    // MARK: - Dependencies
    private let dataManager: DataManager
    
    // MARK: - Published Properties
    var matches: [Match] = []
    var showingAddMatch = false
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Check if there are no matches to display
    var isEmpty: Bool {
        return matches.isEmpty
    }
    
    /// Get the count of matches
    var matchCount: Int {
        return matches.count
    }
    
    /// Get matches sorted by date (newest first)
    var sortedMatches: [Match] {
        return matches.sorted { $0.date > $1.date }
    }
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        print("🏗️ MatchListViewModel: Initializing with DataManager")
        loadMatches()
    }
    
    // MARK: - Data Loading
    
    /// Load matches from DataManager
    private func loadMatches() {
        print("🔄 MatchListViewModel: Loading matches from DataManager")
        isLoading = true
        errorMessage = nil
        
        // Simulate async loading for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.matches = self.dataManager.matches
            self.isLoading = false
            print("✅ MatchListViewModel: Loaded \(self.matches.count) matches")
        }
    }
    
    /// Refresh matches from DataManager
    func refreshMatches() {
        print("🔄 MatchListViewModel: Refreshing matches")
        loadMatches()
    }
    
    // MARK: - Actions
    
    /// Show the Add Match sheet
    func showAddMatch() {
        print("➕ MatchListViewModel: Showing Add Match sheet")
        showingAddMatch = true
    }
    
    /// Hide the Add Match sheet
    func hideAddMatch() {
        print("❌ MatchListViewModel: Hiding Add Match sheet")
        showingAddMatch = false
    }
    
    /// Handle match selection for navigation
    func selectMatch(_ match: Match) {
        print("🎾 MatchListViewModel: Selected match \(match.id)")
        // TODO: Navigate to match detail/edit view
        // This will be implemented when we add navigation
    }
    
    /// Delete a match
    func deleteMatch(_ match: Match) {
        print("🗑️ MatchListViewModel: Deleting match \(match.id)")
        dataManager.deleteMatch(match)
        refreshMatches()
    }
    
    // MARK: - Helper Methods
    
    /// Get opponent name for a match
    func getOpponentName(for match: Match) -> String {
        // TODO: Implement when we have player/team data loaded
        if match.type == .singles {
            return "Opponent"
        } else {
            return "Opponent Team"
        }
    }
    
    /// Get formatted date string for a match
    func getFormattedDate(for match: Match) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: match.date)
    }
    
    /// Get formatted score string for a match
    func getFormattedScore(for match: Match) -> String {
        if match.setScores.isEmpty {
            return "0-0"
        } else {
            let scores = match.setScores.map { "\($0.playerAPoints)-\($0.playerBPoints)" }
            return scores.joined(separator: ", ")
        }
    }
    
    /// Get match type display string
    func getMatchTypeString(for match: Match) -> String {
        return match.type.displayName
    }
}

// MARK: - Preview Support
extension MatchListViewModel {
    /// Create a preview instance with sample data
    static func preview() -> MatchListViewModel {
        let viewModel = MatchListViewModel()
        viewModel.matches = Match.sampleMatches
        return viewModel
    }
}

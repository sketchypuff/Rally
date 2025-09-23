//
//  AddMatchViewModel.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// ViewModel for Add Match flow (S-002, S-003) & F-002
/// Handles business logic for match creation and setup
/// Follows MVVM pattern by separating view logic from data management
@Observable
final class AddMatchViewModel {
    // MARK: - Dependencies
    let dataManager: DataManager
    
    // MARK: - Published Properties
    var players: [Player] = []
    var teams: [Team] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Match Setup Properties
    var matchType: MatchType = .singles
    var selectedPlayerAId: UUID?
    var selectedPlayerBId: UUID?
    var selectedTeamAId: UUID?
    var selectedTeamBId: UUID?
    var targetPoints: Int = 21
    var bestOfSets: Int = 3
    var notes: String = ""
    var isDeuceEnabled: Bool = true
    
    // MARK: - Validation Properties
    var canStartMatch: Bool {
        return validateMatchSetup()
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if matchType == .singles {
            if selectedPlayerAId == nil {
                errors.append("Please select Player A")
            }
            if selectedPlayerBId == nil {
                errors.append("Please select Player B")
            }
            if selectedPlayerAId == selectedPlayerBId {
                errors.append("Player A and Player B must be different")
            }
        } else {
            if selectedTeamAId == nil {
                errors.append("Please select Team A")
            }
            if selectedTeamBId == nil {
                errors.append("Please select Team B")
            }
            if selectedTeamAId == selectedTeamBId {
                errors.append("Team A and Team B must be different")
            }
        }
        
        if targetPoints < 1 {
            errors.append("Target points must be at least 1")
        }
        
        if bestOfSets < 1 || bestOfSets % 2 == 0 {
            errors.append("Best of sets must be an odd number (1, 3, 5, etc.)")
        }
        
        return errors
    }
    
    // MARK: - Computed Properties
    
    /// Get available players for selection
    var availablePlayers: [Player] {
        return players.sorted { $0.name < $1.name }
    }
    
    /// Get available teams for selection
    var availableTeams: [Team] {
        return teams.filter { $0.isValidForDoubles }.sorted { ($0.name ?? "Unnamed") < ($1.name ?? "Unnamed") }
    }
    
    /// Check if there are enough players/teams for match creation
    var hasEnoughParticipants: Bool {
        if matchType == .singles {
            return players.count >= 2
        } else {
            return teams.count >= 2
        }
    }
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        print("🏗️ AddMatchViewModel: Initializing with DataManager")
        loadData()
    }
    
    // MARK: - Data Loading
    
    /// Load players and teams from DataManager
    private func loadData() {
        print("🔄 AddMatchViewModel: Loading players and teams from DataManager")
        isLoading = true
        errorMessage = nil
        
        // Simulate async loading for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.players = self.dataManager.players
            self.teams = self.dataManager.teams
            self.isLoading = false
            print("✅ AddMatchViewModel: Loaded \(self.players.count) players and \(self.teams.count) teams")
        }
    }
    
    /// Refresh data from DataManager
    func refreshData() {
        print("🔄 AddMatchViewModel: Refreshing data")
        loadData()
    }
    
    // MARK: - Match Setup Actions
    
    /// Set match type and reset selections
    func setMatchType(_ type: MatchType) {
        print("🎾 AddMatchViewModel: Setting match type to \(type)")
        matchType = type
        
        // Reset selections when changing match type
        selectedPlayerAId = nil
        selectedPlayerBId = nil
        selectedTeamAId = nil
        selectedTeamBId = nil
    }
    
    /// Set target points for the match
    func setTargetPoints(_ points: Int) {
        print("🎯 AddMatchViewModel: Setting target points to \(points)")
        targetPoints = max(1, points)
    }
    
    /// Set best of sets for the match
    func setBestOfSets(_ sets: Int) {
        print("🏆 AddMatchViewModel: Setting best of sets to \(sets)")
        // Ensure it's an odd number
        let oddSets = sets % 2 == 0 ? sets + 1 : sets
        bestOfSets = max(1, oddSets)
    }
    
    /// Set notes for the match
    func setNotes(_ notes: String) {
        print("📝 AddMatchViewModel: Setting notes")
        self.notes = notes
    }
    
    /// Toggle deuce rule
    func toggleDeuce() {
        print("🔄 AddMatchViewModel: Toggling deuce rule to \(!isDeuceEnabled)")
        isDeuceEnabled.toggle()
    }
    
    // MARK: - Player/Team Selection
    
    /// Select player A for singles match
    func selectPlayerA(_ playerId: UUID?) {
        print("👤 AddMatchViewModel: Selecting player A: \(playerId?.uuidString ?? "nil")")
        selectedPlayerAId = playerId
    }
    
    /// Select player B for singles match
    func selectPlayerB(_ playerId: UUID?) {
        print("👤 AddMatchViewModel: Selecting player B: \(playerId?.uuidString ?? "nil")")
        selectedPlayerBId = playerId
    }
    
    /// Select team A for doubles match
    func selectTeamA(_ teamId: UUID?) {
        print("👥 AddMatchViewModel: Selecting team A: \(teamId?.uuidString ?? "nil")")
        selectedTeamAId = teamId
    }
    
    /// Select team B for doubles match
    func selectTeamB(_ teamId: UUID?) {
        print("👥 AddMatchViewModel: Selecting team B: \(teamId?.uuidString ?? "nil")")
        selectedTeamBId = teamId
    }
    
    // MARK: - Match Creation
    
    /// Create a new match with current setup
    func createMatch() -> Match? {
        print("🎾 AddMatchViewModel: Creating new match")
        
        guard validateMatchSetup() else {
            print("❌ AddMatchViewModel: Match validation failed")
            return nil
        }
        
        let match = Match(
            type: matchType,
            playerAId: matchType == .singles ? selectedPlayerAId : nil,
            playerBId: matchType == .singles ? selectedPlayerBId : nil,
            teamAId: matchType == .doubles ? selectedTeamAId : nil,
            teamBId: matchType == .doubles ? selectedTeamBId : nil,
            targetPoints: targetPoints,
            bestOfSets: bestOfSets,
            notes: notes
        )
        
        print("✅ AddMatchViewModel: Created match: \(match.debugDescription)")
        return match
    }
    
    /// Start a live match with current setup
    func startLiveMatch() -> (Match, LiveMatchState)? {
        print("🎾 AddMatchViewModel: Starting live match")
        
        guard let match = createMatch() else {
            print("❌ AddMatchViewModel: Failed to create match for live scoring")
            return nil
        }
        
        let liveState = LiveMatchState(matchId: match.id)
        
        print("✅ AddMatchViewModel: Started live match: \(match.debugDescription)")
        return (match, liveState)
    }
    
    /// Save a completed match with current setup
    func saveCompletedMatch() -> Match? {
        print("💾 AddMatchViewModel: Saving completed match")
        
        guard let match = createMatch() else {
            print("❌ AddMatchViewModel: Failed to create match for saving")
            return nil
        }
        
        // Add the match to DataManager
        dataManager.addMatch(match)
        
        print("✅ AddMatchViewModel: Saved completed match: \(match.debugDescription)")
        return match
    }
    
    // MARK: - Helper Methods
    
    /// Validate match setup
    private func validateMatchSetup() -> Bool {
        return validationErrors.isEmpty
    }
    
    /// Get player by ID
    func getPlayer(by id: UUID) -> Player? {
        return players.first { $0.id == id }
    }
    
    /// Get team by ID
    func getTeam(by id: UUID) -> Team? {
        return teams.first { $0.id == id }
    }
    
    /// Reset all form data
    func resetForm() {
        print("🔄 AddMatchViewModel: Resetting form")
        matchType = .singles
        selectedPlayerAId = nil
        selectedPlayerBId = nil
        selectedTeamAId = nil
        selectedTeamBId = nil
        targetPoints = 21
        bestOfSets = 3
        notes = ""
        isDeuceEnabled = true
        errorMessage = nil
    }
}

// MARK: - Preview Support
extension AddMatchViewModel {
    /// Create a preview instance with sample data
    static func preview() -> AddMatchViewModel {
        let viewModel = AddMatchViewModel()
        // Add sample data for preview
        return viewModel
    }
}

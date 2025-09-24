//
//  LogCompletedMatchViewModel.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// ViewModel for Log Completed Match flow
/// Handles business logic for logging completed matches with scores
/// Follows MVVM pattern by separating view logic from data management
@Observable
final class LogCompletedMatchViewModel {
    // MARK: - Dependencies
    let dataManager: DataManager
    
    // MARK: - Published Properties
    var players: [Player] = []
    var teams: [Team] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Match Properties
    var matchDate: Date = Date()
    var matchType: MatchType = .singles
    var selectedPlayerAId: UUID?
    var selectedPlayerBId: UUID?
    var selectedTeamAId: UUID?
    var selectedTeamBId: UUID?
    var targetPoints: Int = 21
    var bestOfSets: Int = 3
    var notes: String = ""
    
    // MARK: - Sets Management
    var setScores: [SetScore] = []
    var isDeuceEnabled: Bool = true
    
    // MARK: - Validation Properties
    var canSaveMatch: Bool {
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
        
        if setScores.isEmpty {
            errors.append("Please enter at least one set score")
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
        print("🏗️ LogCompletedMatchViewModel: Initializing with DataManager")
        initializeDefaultSets()
        loadData()
    }
    
    // MARK: - Data Loading
    
    /// Load players and teams from DataManager
    private func loadData() {
        print("🔄 LogCompletedMatchViewModel: Loading players and teams from DataManager")
        isLoading = true
        errorMessage = nil
        
        // Simulate async loading for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.players = self.dataManager.players
            self.teams = self.dataManager.teams
            self.isLoading = false
            print("✅ LogCompletedMatchViewModel: Loaded \(self.players.count) players and \(self.teams.count) teams")
        }
    }
    
    /// Refresh data from DataManager
    func refreshData() {
        print("🔄 LogCompletedMatchViewModel: Refreshing data")
        loadData()
    }
    
    // MARK: - Match Setup Actions
    
    /// Set match type and reset selections
    func setMatchType(_ type: MatchType) {
        print("🎾 LogCompletedMatchViewModel: Setting match type to \(type)")
        matchType = type
        
        // Reset selections when changing match type
        selectedPlayerAId = nil
        selectedPlayerBId = nil
        selectedTeamAId = nil
        selectedTeamBId = nil
    }
    
    /// Set target points for the match
    func setTargetPoints(_ points: Int) {
        print("🎯 LogCompletedMatchViewModel: Setting target points to \(points)")
        targetPoints = max(1, points)
    }
    
    /// Set best of sets for the match
    func setBestOfSets(_ sets: Int) {
        print("🏆 LogCompletedMatchViewModel: Setting best of sets to \(sets)")
        // Ensure it's an odd number
        let oddSets = sets % 2 == 0 ? sets + 1 : sets
        bestOfSets = max(1, oddSets)
    }
    
    /// Set notes for the match
    func setNotes(_ notes: String) {
        print("📝 LogCompletedMatchViewModel: Setting notes")
        self.notes = notes
    }
    
    /// Toggle deuce rule
    func toggleDeuce() {
        print("🔄 LogCompletedMatchViewModel: Toggling deuce rule to \(!isDeuceEnabled)")
        isDeuceEnabled.toggle()
    }
    
    // MARK: - Player/Team Selection
    
    /// Select player A for singles match
    func selectPlayerA(_ playerId: UUID?) {
        print("👤 LogCompletedMatchViewModel: Selecting player A: \(playerId?.uuidString ?? "nil")")
        selectedPlayerAId = playerId
    }
    
    /// Select player B for singles match
    func selectPlayerB(_ playerId: UUID?) {
        print("👤 LogCompletedMatchViewModel: Selecting player B: \(playerId?.uuidString ?? "nil")")
        selectedPlayerBId = playerId
    }
    
    /// Select team A for doubles match
    func selectTeamA(_ teamId: UUID?) {
        print("👥 LogCompletedMatchViewModel: Selecting team A: \(teamId?.uuidString ?? "nil")")
        selectedTeamAId = teamId
    }
    
    /// Select team B for doubles match
    func selectTeamB(_ teamId: UUID?) {
        print("👥 LogCompletedMatchViewModel: Selecting team B: \(teamId?.uuidString ?? "nil")")
        selectedTeamBId = teamId
    }
    
    // MARK: - Sets Management
    
    /// Initialize with 3 default blank sets
    private func initializeDefaultSets() {
        print("🎾 LogCompletedMatchViewModel: Initializing 3 default blank sets")
        setScores = [
            SetScore(),
            SetScore(),
            SetScore()
        ]
    }
    
    /// Add a new set
    func addSet() {
        print("➕ LogCompletedMatchViewModel: Adding new set")
        setScores.append(SetScore())
    }
    
    /// Remove a set at specific index
    func removeSet(at index: Int) {
        guard index >= 0 && index < setScores.count else {
            print("❌ LogCompletedMatchViewModel: Invalid set index for removal: \(index)")
            return
        }
        
        print("➖ LogCompletedMatchViewModel: Removing set at index \(index)")
        setScores.remove(at: index)
    }
    
    /// Update set score at specific index
    func updateSetScore(at index: Int, playerAPoints: Int, playerBPoints: Int) {
        guard index >= 0 && index < setScores.count else {
            print("❌ LogCompletedMatchViewModel: Invalid set index for update: \(index)")
            return
        }
        
        print("📊 LogCompletedMatchViewModel: Updating set \(index + 1) score: A=\(playerAPoints), B=\(playerBPoints)")
        setScores[index] = SetScore(playerAPoints: playerAPoints, playerBPoints: playerBPoints)
    }
    
    /// Get player A name for display
    func getPlayerAName() -> String {
        if matchType == .singles {
            return getPlayer(by: selectedPlayerAId)?.name ?? "Select Player A"
        } else {
            return getTeam(by: selectedTeamAId)?.name ?? "Select Team A"
        }
    }
    
    /// Get player B name for display
    func getPlayerBName() -> String {
        if matchType == .singles {
            return getPlayer(by: selectedPlayerBId)?.name ?? "Select Player B"
        } else {
            return getTeam(by: selectedTeamBId)?.name ?? "Select Team B"
        }
    }
    
    // MARK: - Match Creation
    
    /// Create a completed match with current setup and scores
    func createCompletedMatch() -> Match? {
        print("🎾 LogCompletedMatchViewModel: Creating completed match")
        
        guard validateMatchSetup() else {
            print("❌ LogCompletedMatchViewModel: Match validation failed")
            return nil
        }
        
        var match = Match(
            type: matchType,
            playerAId: matchType == .singles ? selectedPlayerAId : nil,
            playerBId: matchType == .singles ? selectedPlayerBId : nil,
            teamAId: matchType == .doubles ? selectedTeamAId : nil,
            teamBId: matchType == .doubles ? selectedTeamBId : nil,
            targetPoints: targetPoints,
            bestOfSets: bestOfSets,
            notes: notes
        )
        
        // Set the match date
        match.date = matchDate
        
        // Set the completed set scores
        match.setScores = setScores
        
        // Determine match result based on set scores
        match.result = determineMatchResult()
        
        print("✅ LogCompletedMatchViewModel: Created completed match: \(match.debugDescription)")
        return match
    }
    
    /// Save the completed match
    func saveCompletedMatch() -> Match? {
        print("💾 LogCompletedMatchViewModel: Saving completed match")
        
        guard let match = createCompletedMatch() else {
            print("❌ LogCompletedMatchViewModel: Failed to create match for saving")
            return nil
        }
        
        // Add the match to DataManager
        dataManager.addMatch(match)
        
        print("✅ LogCompletedMatchViewModel: Saved completed match: \(match.debugDescription)")
        return match
    }
    
    // MARK: - Helper Methods
    
    /// Validate match setup
    private func validateMatchSetup() -> Bool {
        return validationErrors.isEmpty
    }
    
    /// Get player by ID
    func getPlayer(by id: UUID?) -> Player? {
        guard let id = id else { return nil }
        return players.first { $0.id == id }
    }
    
    /// Get team by ID
    func getTeam(by id: UUID?) -> Team? {
        guard let id = id else { return nil }
        return teams.first { $0.id == id }
    }
    
    /// Determine match result based on set scores
    private func determineMatchResult() -> MatchResult {
        guard !setScores.isEmpty else { return .inProgress }
        
        var playerASetsWon = 0
        var playerBSetsWon = 0
        
        for setScore in setScores {
            if setScore.playerAPoints > setScore.playerBPoints {
                playerASetsWon += 1
            } else if setScore.playerBPoints > setScore.playerAPoints {
                playerBSetsWon += 1
            }
        }
        
        // Assuming the current user is Player A
        if playerASetsWon > playerBSetsWon {
            return .won
        } else if playerBSetsWon > playerASetsWon {
            return .lost
        } else {
            return .inProgress
        }
    }
    
    /// Reset all form data
    func resetForm() {
        print("🔄 LogCompletedMatchViewModel: Resetting form")
        matchDate = Date()
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
        initializeDefaultSets()
    }
}

// MARK: - Preview Support
extension LogCompletedMatchViewModel {
    /// Create a preview instance with sample data
    static func preview() -> LogCompletedMatchViewModel {
        let viewModel = LogCompletedMatchViewModel()
        // Add sample data for preview
        return viewModel
    }
}

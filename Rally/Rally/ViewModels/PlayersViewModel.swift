//
//  PlayersViewModel.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// ViewModel for Players & Teams management
/// Handles business logic for player and team operations
/// Follows MVVM pattern by separating view logic from data management
@Observable
final class PlayersViewModel {
    // MARK: - Dependencies
    private let dataManager: DataManager
    
    // MARK: - Published Properties
    var players: [Player] = []
    var teams: [Team] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Check if there are no players
    var hasNoPlayers: Bool {
        return players.isEmpty
    }
    
    /// Check if there are no teams
    var hasNoTeams: Bool {
        return teams.isEmpty
    }
    
    /// Get the count of players
    var playerCount: Int {
        return players.count
    }
    
    /// Get the count of teams
    var teamCount: Int {
        return teams.count
    }
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        print("🏗️ PlayersViewModel: Initializing with DataManager")
        loadData()
    }
    
    // MARK: - Data Loading
    
    /// Load players and teams from DataManager
    private func loadData() {
        print("🔄 PlayersViewModel: Loading players and teams from DataManager")
        isLoading = true
        errorMessage = nil
        
        // Simulate async loading for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.players = self.dataManager.players
            self.teams = self.dataManager.teams
            self.isLoading = false
            print("✅ PlayersViewModel: Loaded \(self.players.count) players and \(self.teams.count) teams")
        }
    }
    
    /// Refresh data from DataManager
    func refreshData() {
        print("🔄 PlayersViewModel: Refreshing data")
        loadData()
    }
    
    // MARK: - Player Actions
    
    /// Add a new player
    func addPlayer(_ player: Player) {
        print("➕ PlayersViewModel: Adding player \(player.name)")
        dataManager.addPlayer(player)
        refreshData()
    }
    
    /// Update an existing player
    func updatePlayer(_ player: Player) {
        print("✏️ PlayersViewModel: Updating player \(player.name)")
        dataManager.updatePlayer(player)
        refreshData()
    }
    
    /// Delete a player
    func deletePlayer(_ player: Player) {
        print("🗑️ PlayersViewModel: Deleting player \(player.name)")
        dataManager.deletePlayer(player)
        refreshData()
    }
    
    // MARK: - Team Actions
    
    /// Add a new team
    func addTeam(_ team: Team) {
        print("➕ PlayersViewModel: Adding team \(team.name ?? "Unnamed")")
        dataManager.addTeam(team)
        refreshData()
    }
    
    /// Update an existing team
    func updateTeam(_ team: Team) {
        print("✏️ PlayersViewModel: Updating team \(team.name ?? "Unnamed")")
        dataManager.updateTeam(team)
        refreshData()
    }
    
    /// Delete a team
    func deleteTeam(_ team: Team) {
        print("🗑️ PlayersViewModel: Deleting team \(team.name ?? "Unnamed")")
        dataManager.deleteTeam(team)
        refreshData()
    }
    
    // MARK: - Helper Methods
    
    /// Get player by ID
    func getPlayer(by id: UUID) -> Player? {
        return players.first { $0.id == id }
    }
    
    /// Get team by ID
    func getTeam(by id: UUID) -> Team? {
        return teams.first { $0.id == id }
    }
    
    /// Check if a team can be created (has enough players)
    func canCreateTeam() -> Bool {
        return players.count >= 2
    }
    
    /// Get available players for team creation
    func getAvailablePlayers() -> [Player] {
        return players
    }
}

// MARK: - Preview Support
extension PlayersViewModel {
    /// Create a preview instance with sample data
    static func preview() -> PlayersViewModel {
        let viewModel = PlayersViewModel()
        // TODO: Add sample data when Player and Team models are available
        return viewModel
    }
}

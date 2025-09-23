//
//  DataManager.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// Data manager for handling local storage of all app data
/// Implements local storage using UserDefaults and file system
@Observable
final class DataManager {
    // MARK: - Singleton
    static let shared = DataManager()
    
    // MARK: - Data Properties
    var players: [Player] = []
    var teams: [Team] = []
    var matches: [Match] = []
    var settings: Settings = Settings.default
    var liveMatchState: LiveMatchState?
    
    // MARK: - Storage Keys
    private enum StorageKeys {
        static let players = "Rally_Players"
        static let teams = "Rally_Teams"
        static let matches = "Rally_Matches"
        static let settings = "Rally_Settings"
        static let liveMatchState = "Rally_LiveMatchState"
    }
    
    // MARK: - Initialization
    private init() {
        loadAllData()
    }
    
    // MARK: - Data Loading
    private func loadAllData() {
        print("🔄 DataManager: Loading all data from local storage")
        loadPlayers()
        loadTeams()
        loadMatches()
        loadSettings()
        loadLiveMatchState()
        print("✅ DataManager: Data loading completed")
    }
    
    private func loadPlayers() {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.players),
           let decodedPlayers = try? JSONDecoder().decode([Player].self, from: data) {
            players = decodedPlayers
            print("📱 DataManager: Loaded \(players.count) players")
        } else {
            players = []
            print("📱 DataManager: No players found, starting with empty array")
        }
    }
    
    private func loadTeams() {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.teams),
           let decodedTeams = try? JSONDecoder().decode([Team].self, from: data) {
            teams = decodedTeams
            print("📱 DataManager: Loaded \(teams.count) teams")
        } else {
            teams = []
            print("📱 DataManager: No teams found, starting with empty array")
        }
    }
    
    private func loadMatches() {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.matches),
           let decodedMatches = try? JSONDecoder().decode([Match].self, from: data) {
            matches = decodedMatches.sorted { $0.date > $1.date } // Newest first
            print("📱 DataManager: Loaded \(matches.count) matches")
        } else {
            matches = []
            print("📱 DataManager: No matches found, starting with empty array")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.settings),
           let decodedSettings = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = decodedSettings
            print("📱 DataManager: Loaded settings")
        } else {
            settings = Settings.default
            print("📱 DataManager: No settings found, using defaults")
        }
    }
    
    private func loadLiveMatchState() {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.liveMatchState),
           let decodedState = try? JSONDecoder().decode(LiveMatchState.self, from: data) {
            liveMatchState = decodedState
            print("📱 DataManager: Loaded live match state")
        } else {
            liveMatchState = nil
            print("📱 DataManager: No live match state found")
        }
    }
    
    // MARK: - Data Saving
    private func savePlayers() {
        if let data = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(data, forKey: StorageKeys.players)
            print("💾 DataManager: Saved \(players.count) players")
        } else {
            print("❌ DataManager: Failed to save players")
        }
    }
    
    private func saveTeams() {
        if let data = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(data, forKey: StorageKeys.teams)
            print("💾 DataManager: Saved \(teams.count) teams")
        } else {
            print("❌ DataManager: Failed to save teams")
        }
    }
    
    private func saveMatches() {
        if let data = try? JSONEncoder().encode(matches) {
            UserDefaults.standard.set(data, forKey: StorageKeys.matches)
            print("💾 DataManager: Saved \(matches.count) matches")
        } else {
            print("❌ DataManager: Failed to save matches")
        }
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: StorageKeys.settings)
            print("💾 DataManager: Saved settings")
        } else {
            print("❌ DataManager: Failed to save settings")
        }
    }
    
    private func saveLiveMatchState() {
        if let state = liveMatchState,
           let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: StorageKeys.liveMatchState)
            print("💾 DataManager: Saved live match state")
        } else {
            UserDefaults.standard.removeObject(forKey: StorageKeys.liveMatchState)
            print("💾 DataManager: Cleared live match state")
        }
    }
    
    // MARK: - Public Methods
    
    /// Add a new player
    func addPlayer(_ player: Player) {
        players.append(player)
        savePlayers()
        print("➕ DataManager: Added player: \(player.debugDescription)")
    }
    
    /// Update an existing player
    func updatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
            savePlayers()
            print("✏️ DataManager: Updated player: \(player.debugDescription)")
        }
    }
    
    /// Delete a player
    func deletePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
        savePlayers()
        print("🗑️ DataManager: Deleted player: \(player.debugDescription)")
    }
    
    /// Add a new team
    func addTeam(_ team: Team) {
        teams.append(team)
        saveTeams()
        print("➕ DataManager: Added team: \(team.debugDescription)")
    }
    
    /// Update an existing team
    func updateTeam(_ team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
            saveTeams()
            print("✏️ DataManager: Updated team: \(team.debugDescription)")
        }
    }
    
    /// Delete a team
    func deleteTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
        saveTeams()
        print("🗑️ DataManager: Deleted team: \(team.debugDescription)")
    }
    
    /// Add a new match
    func addMatch(_ match: Match) {
        matches.append(match)
        matches.sort { $0.date > $1.date } // Keep newest first
        saveMatches()
        print("➕ DataManager: Added match: \(match.debugDescription)")
    }
    
    /// Update an existing match
    func updateMatch(_ match: Match) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index] = match
            matches.sort { $0.date > $1.date } // Keep newest first
            saveMatches()
            print("✏️ DataManager: Updated match: \(match.debugDescription)")
        }
    }
    
    /// Delete a match
    func deleteMatch(_ match: Match) {
        matches.removeAll { $0.id == match.id }
        saveMatches()
        print("🗑️ DataManager: Deleted match: \(match.debugDescription)")
    }
    
    /// Update settings
    func updateSettings(_ newSettings: Settings) {
        settings = newSettings
        saveSettings()
        print("⚙️ DataManager: Updated settings: \(settings.debugDescription)")
    }
    
    /// Set live match state
    func setLiveMatchState(_ state: LiveMatchState?) {
        liveMatchState = state
        saveLiveMatchState()
        if let state = state {
            print("🎾 DataManager: Set live match state: \(state.debugDescription)")
        } else {
            print("🎾 DataManager: Cleared live match state")
        }
    }
    
    /// Clear all data (for testing/reset)
    func clearAllData() {
        players = []
        teams = []
        matches = []
        settings = Settings.default
        liveMatchState = nil
        
        UserDefaults.standard.removeObject(forKey: StorageKeys.players)
        UserDefaults.standard.removeObject(forKey: StorageKeys.teams)
        UserDefaults.standard.removeObject(forKey: StorageKeys.matches)
        UserDefaults.standard.removeObject(forKey: StorageKeys.settings)
        UserDefaults.standard.removeObject(forKey: StorageKeys.liveMatchState)
        
        print("🧹 DataManager: Cleared all data")
    }
}

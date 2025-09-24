//
//  LiveScoringViewModel.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// ViewModel for Live Scoring functionality (S-004) & F-003, F-009
/// Handles business logic for live match scoring, undo history, and match management
/// Follows MVVM pattern by separating view logic from data management
@Observable
final class LiveScoringViewModel {
    // MARK: - Dependencies
    private let dataManager: DataManager
    
    // MARK: - Published Properties
    var match: Match
    var liveState: LiveMatchState
    var isLoading = false
    var errorMessage: String?
    var showingAlert = false
    var alertMessage = ""
    
    // MARK: - Computed Properties
    
    /// Get current set score
    var currentSetScore: SetScore {
        return liveState.currentSetPoints
    }
    
    /// Get completed sets
    var completedSets: [SetScore] {
        return liveState.completedSets
    }
    
    /// Get current set number (1-based)
    var currentSetNumber: Int {
        return liveState.currentSetNumber
    }
    
    /// Check if match is completed
    var isMatchCompleted: Bool {
        return match.result != .inProgress
    }
    
    /// Check if current set is completed
    var isCurrentSetCompleted: Bool {
        return isSetWon(by: .playerA) || isSetWon(by: .playerB)
    }
    
    /// Check if match is paused
    var isPaused: Bool {
        return liveState.isPaused
    }
    
    /// Check if undo is available
    var canUndo: Bool {
        return liveState.canUndo
    }
    
    /// Get match duration
    var matchDuration: TimeInterval {
        return liveState.totalDuration
    }
    
    /// Get formatted duration string
    var formattedDuration: String {
        let minutes = Int(matchDuration) / 60
        let seconds = Int(matchDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Get player A name
    var playerAName: String {
        if match.type == .singles {
            return dataManager.players.first { $0.id == match.playerAId }?.name ?? "Player A"
        } else {
            return dataManager.teams.first { $0.id == match.teamAId }?.name ?? "Team A"
        }
    }
    
    /// Get player B name
    var playerBName: String {
        if match.type == .singles {
            return dataManager.players.first { $0.id == match.playerBId }?.name ?? "Player B"
        } else {
            return dataManager.teams.first { $0.id == match.teamBId }?.name ?? "Team B"
        }
    }
    
    /// Get match type display string
    var matchTypeString: String {
        return match.type.displayName
    }
    
    /// Get target points for current set
    var targetPoints: Int {
        return match.targetPoints
    }
    
    /// Get best of sets
    var bestOfSets: Int {
        return match.bestOfSets
    }
    
    /// Check if deuce is enabled
    var isDeuceEnabled: Bool {
        return match.isInDeuce
    }
    
    // MARK: - Initialization
    
    init(match: Match, liveState: LiveMatchState, dataManager: DataManager = DataManager.shared) {
        self.match = match
        self.liveState = liveState
        self.dataManager = dataManager
        print("🏗️ LiveScoringViewModel: Initializing with match \(match.id) and live state")
    }
    
    // MARK: - Scoring Actions
    
    /// Add point to player A
    func addPointToPlayerA() {
        print("➕ LiveScoringViewModel: Adding point to Player A")
        
        guard !isMatchCompleted else {
            print("❌ LiveScoringViewModel: Cannot add point - match is completed")
            return
        }
        
        // Create undo action before making changes
        let undoAction = UndoAction(
            actionType: .pointAdded,
            previousScore: liveState.currentSetPoints,
            setNumber: currentSetNumber
        )
        
        // Add point to player A
        liveState.currentSetPoints.playerAPoints += 1
        
        // Add undo action to history
        liveState.addUndoAction(undoAction)
        
        // Check if set is won
        if isSetWon(by: .playerA) {
            handleSetWon(by: .playerA)
        }
        
        // Save state
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Added point to Player A - Score: \(currentSetScore.debugDescription)")
    }
    
    /// Add point to player B
    func addPointToPlayerB() {
        print("➕ LiveScoringViewModel: Adding point to Player B")
        
        guard !isMatchCompleted else {
            print("❌ LiveScoringViewModel: Cannot add point - match is completed")
            return
        }
        
        // Create undo action before making changes
        let undoAction = UndoAction(
            actionType: .pointAdded,
            previousScore: liveState.currentSetPoints,
            setNumber: currentSetNumber
        )
        
        // Add point to player B
        liveState.currentSetPoints.playerBPoints += 1
        
        // Add undo action to history
        liveState.addUndoAction(undoAction)
        
        // Check if set is won
        if isSetWon(by: .playerB) {
            handleSetWon(by: .playerB)
        }
        
        // Save state
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Added point to Player B - Score: \(currentSetScore.debugDescription)")
    }
    
    /// Remove point from player A
    func removePointFromPlayerA() {
        print("➖ LiveScoringViewModel: Removing point from Player A")
        
        guard !isMatchCompleted else {
            print("❌ LiveScoringViewModel: Cannot remove point - match is completed")
            return
        }
        
        guard liveState.currentSetPoints.playerAPoints > 0 else {
            print("❌ LiveScoringViewModel: Cannot remove point - Player A has 0 points")
            return
        }
        
        // Create undo action before making changes
        let undoAction = UndoAction(
            actionType: .pointRemoved,
            previousScore: liveState.currentSetPoints,
            setNumber: currentSetNumber
        )
        
        // Remove point from player A
        liveState.currentSetPoints.playerAPoints -= 1
        
        // Add undo action to history
        liveState.addUndoAction(undoAction)
        
        // Save state
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Removed point from Player A - Score: \(currentSetScore.debugDescription)")
    }
    
    /// Remove point from player B
    func removePointFromPlayerB() {
        print("➖ LiveScoringViewModel: Removing point from Player B")
        
        guard !isMatchCompleted else {
            print("❌ LiveScoringViewModel: Cannot remove point - match is completed")
            return
        }
        
        guard liveState.currentSetPoints.playerBPoints > 0 else {
            print("❌ LiveScoringViewModel: Cannot remove point - Player B has 0 points")
            return
        }
        
        // Create undo action before making changes
        let undoAction = UndoAction(
            actionType: .pointRemoved,
            previousScore: liveState.currentSetPoints,
            setNumber: currentSetNumber
        )
        
        // Remove point from player B
        liveState.currentSetPoints.playerBPoints -= 1
        
        // Add undo action to history
        liveState.addUndoAction(undoAction)
        
        // Save state
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Removed point from Player B - Score: \(currentSetScore.debugDescription)")
    }
    
    // MARK: - Set Management
    
    /// Advance to next set
    func advanceToNextSet() {
        print("⏭️ LiveScoringViewModel: Advancing to next set")
        
        guard isCurrentSetCompleted else {
            print("❌ LiveScoringViewModel: Cannot advance - current set is not completed")
            alertMessage = "Current set must be completed before advancing"
            showingAlert = true
            return
        }
        
        // Create undo action before making changes
        let undoAction = UndoAction(
            actionType: .setAdvanced,
            previousScore: liveState.currentSetPoints,
            setNumber: currentSetNumber
        )
        
        // Add current set to completed sets
        liveState.completedSets.append(liveState.currentSetPoints)
        
        // Reset current set points
        liveState.currentSetPoints = SetScore()
        
        // Add undo action to history
        liveState.addUndoAction(undoAction)
        
        // Check if match is completed
        if isMatchCompleted {
            handleMatchCompleted()
        }
        
        // Save state
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Advanced to next set - Set \(currentSetNumber) completed")
    }
    
    // MARK: - Undo Functionality
    
    /// Undo last action
    func undoLastAction() {
        print("↩️ LiveScoringViewModel: Undoing last action")
        
        guard canUndo else {
            print("❌ LiveScoringViewModel: Cannot undo - no actions in history")
            return
        }
        
        guard let undoAction = liveState.undoLastAction() else {
            print("❌ LiveScoringViewModel: Failed to get undo action")
            return
        }
        
        // Restore previous score
        liveState.currentSetPoints = undoAction.previousScore
        
        // Save state
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Undid action - \(undoAction.debugDescription)")
    }
    
    // MARK: - Match Control
    
    /// Pause the match
    func pauseMatch() {
        print("⏸️ LiveScoringViewModel: Pausing match")
        
        guard !isMatchCompleted else {
            print("❌ LiveScoringViewModel: Cannot pause - match is completed")
            return
        }
        
        liveState.pause()
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Match paused")
    }
    
    /// Resume the match
    func resumeMatch() {
        print("▶️ LiveScoringViewModel: Resuming match")
        
        guard !isMatchCompleted else {
            print("❌ LiveScoringViewModel: Cannot resume - match is completed")
            return
        }
        
        liveState.resume()
        saveLiveState()
        
        print("✅ LiveScoringViewModel: Match resumed")
    }
    
    /// Save and finish the match
    func saveMatch() {
        print("💾 LiveScoringViewModel: Saving match")
        
        // Update match with current state
        match.setScores = liveState.completedSets
        match.currentSetPoints = liveState.currentSetPoints
        match.isPaused = liveState.isPaused
        match.updatedAt = Date()
        
        // Update match in DataManager
        dataManager.updateMatch(match)
        
        // Clear live state
        dataManager.setLiveMatchState(nil)
        
        print("✅ LiveScoringViewModel: Match saved successfully")
    }
    
    // MARK: - Helper Methods
    
    /// Check if set is won by a player
    private func isSetWon(by player: PlayerSide) -> Bool {
        let score = liveState.currentSetPoints
        let target = targetPoints
        
        switch player {
        case .playerA:
            if isDeuceEnabled {
                // Deuce rule: win by 2, no cap
                return score.playerAPoints >= target && score.playerAPoints - score.playerBPoints >= 2
            } else {
                return score.playerAPoints >= target
            }
        case .playerB:
            if isDeuceEnabled {
                // Deuce rule: win by 2, no cap
                return score.playerBPoints >= target && score.playerBPoints - score.playerAPoints >= 2
            } else {
                return score.playerBPoints >= target
            }
        }
    }
    
    /// Handle set won by a player
    private func handleSetWon(by player: PlayerSide) {
        print("🏆 LiveScoringViewModel: Set won by \(player)")
        
        // Add current set to completed sets
        liveState.completedSets.append(liveState.currentSetPoints)
        
        // Check if match is completed
        if isMatchCompleted {
            handleMatchCompleted()
        }
    }
    
    /// Handle match completion
    private func handleMatchCompleted() {
        print("🎉 LiveScoringViewModel: Match completed")
        
        // Determine winner based on completed sets
        let playerASets = liveState.completedSets.filter { $0.playerAPoints > $0.playerBPoints }.count
        let playerBSets = liveState.completedSets.filter { $0.playerBPoints > $0.playerAPoints }.count
        
        if playerASets > playerBSets {
            match.result = .won
        } else {
            match.result = .lost
        }
        
        // Update match
        match.setScores = liveState.completedSets
        match.currentSetPoints = nil
        match.isPaused = false
        match.updatedAt = Date()
        
        // Update match in DataManager
        dataManager.updateMatch(match)
        
        print("✅ LiveScoringViewModel: Match completed - Result: \(match.result.displayName)")
    }
    
    /// Save live state to DataManager
    private func saveLiveState() {
        dataManager.setLiveMatchState(liveState)
    }
}

// MARK: - Player Side Enum
enum PlayerSide {
    case playerA
    case playerB
}

// MARK: - Preview Support
extension LiveScoringViewModel {
    /// Create a preview instance with sample data
    static func preview() -> LiveScoringViewModel {
        let match = Match.sampleMatches[0]
        let liveState = LiveMatchState(matchId: match.id)
        return LiveScoringViewModel(match: match, liveState: liveState)
    }
}

//
//  LiveMatchState.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation

/// Live match state for tracking ongoing matches
/// D-005: Live Match State with current set points, completed sets, undo history, start time
struct LiveMatchState: Codable {
    var matchId: UUID
    var currentSetPoints: SetScore
    var completedSets: [SetScore]
    var undoHistory: [UndoAction]
    var startTime: Date
    var isPaused: Bool
    var pauseStartTime: Date?
    var totalPauseTime: TimeInterval
    
    init(matchId: UUID) {
        self.matchId = matchId
        self.currentSetPoints = SetScore()
        self.completedSets = []
        self.undoHistory = []
        self.startTime = Date()
        self.isPaused = false
        self.pauseStartTime = nil
        self.totalPauseTime = 0
    }
    
    /// Debug helper for logging live match state
    var debugDescription: String {
        return "LiveMatchState(matchId: \(matchId), currentSet: \(currentSetPoints.debugDescription), completedSets: \(completedSets.count), undoHistory: \(undoHistory.count))"
    }
    
    /// Get current set number (1-based)
    var currentSetNumber: Int {
        return completedSets.count + 1
    }
    
    /// Get total match duration
    var totalDuration: TimeInterval {
        let now = Date()
        let baseDuration = now.timeIntervalSince(startTime)
        return baseDuration - totalPauseTime
    }
    
    /// Check if undo is available
    var canUndo: Bool {
        return !undoHistory.isEmpty
    }
    
    /// Add undo action to history
    mutating func addUndoAction(_ action: UndoAction) {
        undoHistory.append(action)
        // Limit undo history to prevent memory issues
        if undoHistory.count > 50 {
            undoHistory.removeFirst()
        }
    }
    
    /// Undo last action
    mutating func undoLastAction() -> UndoAction? {
        return undoHistory.popLast()
    }
    
    /// Pause the match
    mutating func pause() {
        guard !isPaused else { return }
        isPaused = true
        pauseStartTime = Date()
    }
    
    /// Resume the match
    mutating func resume() {
        guard isPaused else { return }
        isPaused = false
        if let pauseStart = pauseStartTime {
            totalPauseTime += Date().timeIntervalSince(pauseStart)
        }
        pauseStartTime = nil
    }
}

/// Undo action for tracking point changes
struct UndoAction: Codable, Hashable {
    let timestamp: Date
    let actionType: UndoActionType
    let previousScore: SetScore
    let setNumber: Int
    
    init(actionType: UndoActionType, previousScore: SetScore, setNumber: Int) {
        self.timestamp = Date()
        self.actionType = actionType
        self.previousScore = previousScore
        self.setNumber = setNumber
    }
    
    /// Debug helper for logging undo action
    var debugDescription: String {
        return "UndoAction(type: \(actionType), set: \(setNumber), score: \(previousScore.debugDescription))"
    }
}

/// Types of undo actions
enum UndoActionType: String, CaseIterable, Codable {
    case pointAdded = "point_added"
    case pointRemoved = "point_removed"
    case setAdvanced = "set_advanced"
    
    var displayName: String {
        switch self {
        case .pointAdded:
            return "Point Added"
        case .pointRemoved:
            return "Point Removed"
        case .setAdvanced:
            return "Set Advanced"
        }
    }
}

// MARK: - Preview Data
extension LiveMatchState {
    static let sampleState = LiveMatchState(matchId: UUID())
}

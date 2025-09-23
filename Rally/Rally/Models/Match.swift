//
//  Match.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation

/// Match data model for storing match information
/// D-003: Match with id, date/time, type, player/team refs, format, target points, set scores, result, notes, paused flag, timestamps
struct Match: Identifiable, Codable {
    let id: UUID
    var date: Date
    var type: MatchType
    var playerAId: UUID? // For singles
    var playerBId: UUID? // For singles
    var teamAId: UUID? // For doubles
    var teamBId: UUID? // For doubles
    var targetPoints: Int // Points needed to win a set
    var bestOfSets: Int // Must be odd number (1, 3, 5, etc.)
    var setScores: [SetScore] // Completed sets
    var currentSetPoints: SetScore? // Current set in progress
    var result: MatchResult // From your perspective
    var notes: String
    var isPaused: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        type: MatchType,
        playerAId: UUID? = nil,
        playerBId: UUID? = nil,
        teamAId: UUID? = nil,
        teamBId: UUID? = nil,
        targetPoints: Int = 21,
        bestOfSets: Int = 3,
        notes: String = ""
    ) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.playerAId = playerAId
        self.playerBId = playerBId
        self.teamAId = teamAId
        self.teamBId = teamBId
        self.targetPoints = targetPoints
        self.bestOfSets = bestOfSets
        self.setScores = []
        self.currentSetPoints = SetScore()
        self.result = .inProgress
        self.notes = notes
        self.isPaused = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Debug helper for logging match info
    var debugDescription: String {
        return "Match(id: \(id), type: \(type), targetPoints: \(targetPoints), bestOf: \(bestOfSets), sets: \(setScores.count), result: \(result))"
    }
    
    /// Check if match is completed
    var isCompleted: Bool {
        return result != .inProgress
    }
    
    /// Get current set number (1-based)
    var currentSetNumber: Int {
        return setScores.count + 1
    }
    
    /// Check if match is in deuce (both players at target-1)
    var isInDeuce: Bool {
        guard let current = currentSetPoints else { return false }
        return current.playerAPoints >= targetPoints - 1 && current.playerBPoints >= targetPoints - 1
    }
}

/// Match type enum
enum MatchType: String, CaseIterable, Codable {
    case singles = "singles"
    case doubles = "doubles"
    
    var displayName: String {
        return rawValue.capitalized
    }
}

/// Set score data structure
struct SetScore: Codable, Hashable {
    var playerAPoints: Int
    var playerBPoints: Int
    
    init(playerAPoints: Int = 0, playerBPoints: Int = 0) {
        self.playerAPoints = playerAPoints
        self.playerBPoints = playerBPoints
    }
    
    /// Debug helper for logging set score
    var debugDescription: String {
        return "SetScore(A: \(playerAPoints), B: \(playerBPoints))"
    }
}

/// Match result from your perspective
enum MatchResult: String, CaseIterable, Codable {
    case inProgress = "in_progress"
    case won = "won"
    case lost = "lost"
    
    var displayName: String {
        switch self {
        case .inProgress:
            return "In Progress"
        case .won:
            return "Won"
        case .lost:
            return "Lost"
        }
    }
}

// MARK: - Preview Data
extension Match {
    static let sampleMatches = [
        Match(
            type: .singles,
            playerAId: UUID(),
            playerBId: UUID(),
            targetPoints: 21,
            bestOfSets: 3,
            notes: "Great match!"
        ),
        Match(
            type: .doubles,
            teamAId: UUID(),
            teamBId: UUID(),
            targetPoints: 21,
            bestOfSets: 3,
            notes: "Intense doubles match"
        )
    ]
}

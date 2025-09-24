//
//  Team.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation

/// Team data model for doubles teams
/// D-002: Team with id, name (optional), list of player ids
struct Team: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String?
    var playerIds: [UUID] // References to Player objects
    
    init(name: String? = nil, playerIds: [UUID] = []) {
        self.id = UUID()
        self.name = name
        self.playerIds = playerIds
    }
    
    /// Convenience initializer for creating team with players
    init(name: String? = nil, players: [Player]) {
        self.id = UUID()
        self.name = name
        self.playerIds = players.map { $0.id }
    }
    
    /// Debug helper for logging team info
    var debugDescription: String {
        return "Team(id: \(id), name: \(name ?? "Unnamed"), playerCount: \(playerIds.count))"
    }
    
    /// Check if team has the minimum required players (2 for doubles)
    var isValidForDoubles: Bool {
        return playerIds.count >= 2
    }
    
    /// Create a copy of this team with updated fields but same ID
    func updated(name: String? = nil, playerIds: [UUID]? = nil) -> Team {
        var updatedTeam = self
        if let name = name {
            updatedTeam.name = name
        }
        if let playerIds = playerIds {
            updatedTeam.playerIds = playerIds
        }
        return updatedTeam
    }
}

// MARK: - Preview Data
extension Team {
    static let sampleTeams = [
        Team(name: "Team Alpha", playerIds: []),
        Team(name: "Team Beta", playerIds: []),
        Team(name: "Dynamic Duo", playerIds: [])
    ]
}

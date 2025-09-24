//
//  Player.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// Player data model for individual players
/// D-001: Player with id, name, photo (optional), notes
struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var photo: Data? // Optional photo data
    var notes: String
    
    init(name: String, photo: Data? = nil, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.photo = photo
        self.notes = notes
    }
    
    /// Create a copy of this player with updated fields but same ID
    func updated(name: String? = nil, photo: Data? = nil, notes: String? = nil) -> Player {
        var updatedPlayer = self
        if let name = name {
            updatedPlayer.name = name
        }
        if let photo = photo {
            updatedPlayer.photo = photo
        }
        if let notes = notes {
            updatedPlayer.notes = notes
        }
        return updatedPlayer
    }
    
    /// Debug helper for logging player info
    var debugDescription: String {
        return "Player(id: \(id), name: \(name), hasPhoto: \(photo != nil), notes: \(notes))"
    }
}

// MARK: - Preview Data
extension Player {
    static let samplePlayers = [
        Player(name: "John Doe", notes: "Strong backhand"),
        Player(name: "Jane Smith", notes: "Great at net play"),
        Player(name: "Mike Johnson", notes: "Powerful smashes")
    ]
}

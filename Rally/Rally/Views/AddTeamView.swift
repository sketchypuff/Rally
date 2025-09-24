//
//  AddTeamView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Add Team view for creating new teams
/// Part of B-007 Player & Team Management implementation
struct AddTeamView: View {
    let viewModel: PlayersViewModel
    
    // MARK: - State Management
    @State private var teamName = ""
    @State private var selectedPlayers: Set<UUID> = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Computed Properties
    private var availablePlayers: [Player] {
        viewModel.getAvailablePlayers()
    }
    
    private var canCreateTeam: Bool {
        selectedPlayers.count >= 2
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Team Details")) {
                    // Team name field
                    TextField("Team Name (Optional)", text: $teamName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Select Players")) {
                    if availablePlayers.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No Players Available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Add players first before creating teams")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(availablePlayers) { player in
                            TeamPlayerSelectionRow(
                                player: player,
                                isSelected: selectedPlayers.contains(player.id),
                                onToggle: { togglePlayer(player.id) }
                            )
                        }
                    }
                }
                
                if !availablePlayers.isEmpty {
                    Section(footer: Text("Select at least 2 players to create a team")) {
                        HStack {
                            Text("Selected Players:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(selectedPlayers.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(canCreateTeam ? .green : .red)
                        }
                    }
                }
            }
            .navigationTitle("Add Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTeam()
                    }
                    .disabled(!canCreateTeam)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Actions
    
    private func togglePlayer(_ playerId: UUID) {
        print("🔄 AddTeamView: Toggling player selection for ID: \(playerId)")
        if selectedPlayers.contains(playerId) {
            selectedPlayers.remove(playerId)
        } else {
            selectedPlayers.insert(playerId)
        }
        print("📊 AddTeamView: Selected players count: \(selectedPlayers.count)")
    }
    
    private func saveTeam() {
        print("💾 AddTeamView: Saving new team")
        
        guard canCreateTeam else {
            alertMessage = "Please select at least 2 players to create a team"
            showingAlert = true
            return
        }
        
        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? nil : trimmedName
        
        let newTeam = Team(
            name: finalName,
            playerIds: Array(selectedPlayers)
        )
        
        viewModel.addTeam(newTeam)
        print("✅ AddTeamView: Team saved successfully with \(selectedPlayers.count) players")
        dismiss()
    }
}

// MARK: - Team Player Selection Row
struct TeamPlayerSelectionRow: View {
    let player: Player
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isSelected ? .accentColor : .secondary)
            
            // Player avatar
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.body)
                        .foregroundColor(.accentColor)
                )
            
            // Player info
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !player.notes.isEmpty {
                    Text(player.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

// MARK: - Preview
#Preview {
    AddTeamView(viewModel: PlayersViewModel())
}

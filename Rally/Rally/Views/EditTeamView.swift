//
//  EditTeamView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Edit Team view for modifying existing teams
/// Part of B-007 Player & Team Management implementation
struct EditTeamView: View {
    let team: Team
    let viewModel: PlayersViewModel
    
    // MARK: - State Management
    @State private var teamName: String
    @State private var selectedPlayers: Set<UUID>
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
    
    // MARK: - Initialization
    init(team: Team, viewModel: PlayersViewModel) {
        self.team = team
        self.viewModel = viewModel
        self._teamName = State(initialValue: team.name ?? "")
        self._selectedPlayers = State(initialValue: Set(team.playerIds))
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
                            
                            Text("Add players first before editing teams")
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
                    Section(footer: Text("Select at least 2 players to update the team")) {
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
            .navigationTitle("Edit Team")
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
        print("🔄 EditTeamView: Toggling player selection for ID: \(playerId)")
        if selectedPlayers.contains(playerId) {
            selectedPlayers.remove(playerId)
        } else {
            selectedPlayers.insert(playerId)
        }
        print("📊 EditTeamView: Selected players count: \(selectedPlayers.count)")
    }
    
    private func saveTeam() {
        print("💾 EditTeamView: Saving updated team")
        
        guard canCreateTeam else {
            alertMessage = "Please select at least 2 players to update the team"
            showingAlert = true
            return
        }
        
        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? nil : trimmedName
        
        // Create updated team with same ID
        let updatedTeam = team.updated(
            name: finalName,
            playerIds: Array(selectedPlayers)
        )
        
        viewModel.updateTeam(updatedTeam)
        print("✅ EditTeamView: Team updated successfully with \(selectedPlayers.count) players")
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    EditTeamView(
        team: Team(name: "Team Alpha", playerIds: []),
        viewModel: PlayersViewModel()
    )
}

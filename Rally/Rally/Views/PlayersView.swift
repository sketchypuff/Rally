//
//  PlayersView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Players management view - S-006 implementation for B-007
/// Two categories: individual players and teams
/// Uses MVVM pattern with PlayersViewModel
struct PlayersView: View {
    let viewModel: PlayersViewModel
    
    // MARK: - State Management
    @State private var showingAddPlayer = false
    @State private var showingAddTeam = false
    @State private var editingPlayer: Player?
    @State private var editingTeam: Team?
    @State private var selectedTab = 0 // 0 for players, 1 for teams
    
    // MARK: - Initialization
    init(viewModel: PlayersViewModel = PlayersViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab picker for Players/Teams
                Picker("Category", selection: $selectedTab) {
                    Text("Players").tag(0)
                    Text("Teams").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                if selectedTab == 0 {
                    playersContent
                } else {
                    teamsContent
                }
            }
            .navigationTitle("Players & teams")
            .navigationBarTitleDisplayMode(.inline)
            .font(.title2)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == 0 {
                            showingAddPlayer = true
                        } else {
                            showingAddTeam = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAddTeam) {
                AddTeamView(viewModel: viewModel)
            }
            .sheet(item: $editingPlayer) { player in
                EditPlayerView(player: player, viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingTeam) { team in
                EditTeamView(team: team, viewModel: viewModel)
            }
            .onAppear {
                print("🔄 PlayersView: View appeared, refreshing data")
                viewModel.refreshData()
            }
        }
    }
    
    // MARK: - Players Content
    private var playersContent: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.hasNoPlayers {
                emptyPlayersView
            } else {
                playersList
            }
        }
    }
    
    // MARK: - Teams Content
    private var teamsContent: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.hasNoTeams {
                emptyTeamsView
            } else {
                teamsList
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty Players View
    private var emptyPlayersView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Players Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first player to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingAddPlayer = true
            }) {
                Label("Add Player", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty Teams View
    private var emptyTeamsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Teams Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create teams for doubles matches")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if viewModel.canCreateTeam() {
                Button(action: {
                    showingAddTeam = true
                }) {
                    Label("Add Team", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
            } else {
                VStack(spacing: 12) {
                    Text("Need at least 2 players to create teams")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        selectedTab = 0
                        showingAddPlayer = true
                    }) {
                        Label("Add Players First", systemImage: "person.badge.plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Players List
    private var playersList: some View {
        List {
            ForEach(viewModel.players) { player in
                PlayerRowView(
                    player: player,
                    onEdit: { editingPlayer = player },
                    onDelete: { viewModel.deletePlayer(player) }
                )
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Teams List
    private var teamsList: some View {
        List {
            ForEach(viewModel.teams) { team in
                TeamRowView(
                    team: team,
                    players: viewModel.players,
                    onEdit: { editingTeam = team },
                    onDelete: { viewModel.deleteTeam(team) }
                )
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Player Row View
struct PlayerRowView: View {
    let player: Player
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Player avatar
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                )
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !player.notes.isEmpty {
                    Text(player.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .alert("Delete Player", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete \(player.name)? This action cannot be undone.")
        }
    }
}

// MARK: - Team Row View
struct TeamRowView: View {
    let team: Team
    let players: [Player]
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    // Get team member names
    private var memberNames: [String] {
        team.playerIds.compactMap { id in
            players.first { $0.id == id }?.name
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Team avatar
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                )
            
            // Team info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name ?? "Unnamed Team")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !memberNames.isEmpty {
                    Text(memberNames.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("No members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .alert("Delete Team", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this team? This action cannot be undone.")
        }
    }
}

// MARK: - Preview
#Preview {
    PlayersView()
}

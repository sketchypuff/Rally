//
//  EditPlayerView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Edit Player view for modifying existing players
/// Part of B-007 Player & Team Management implementation
struct EditPlayerView: View {
    let player: Player
    let viewModel: PlayersViewModel
    
    // MARK: - State Management
    @State private var name: String
    @State private var notes: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    init(player: Player, viewModel: PlayersViewModel) {
        self.player = player
        self.viewModel = viewModel
        self._name = State(initialValue: player.name)
        self._notes = State(initialValue: player.notes)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Grabber handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Header with title and buttons
            HStack {
                // Close button
                Button(action: {
                    print("❌ EditPlayerView: User cancelled editing player")
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 30, height: 30)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Title
                Text("Edit player")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Submit button
                Button(action: {
                    savePlayer()
                }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            // Text input fields
            VStack(spacing: 16) {
                // Name field
                TextField("Player name", text: $name)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                // Notes field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                    TextField("Add notes about this player...", text: $notes, axis: .vertical)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .lineLimit(2...4)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Actions
    
    private func savePlayer() {
        print("💾 EditPlayerView: Saving updated player")
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            alertMessage = "Player name cannot be empty"
            showingAlert = true
            return
        }
        
        // Create updated player with same ID (preserve existing photo)
        let updatedPlayer = player.updated(
            name: trimmedName,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        viewModel.updatePlayer(updatedPlayer)
        print("✅ EditPlayerView: Player updated successfully")
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    EditPlayerView(
        player: Player(name: "John Doe", notes: "Great player"),
        viewModel: PlayersViewModel()
    )
}

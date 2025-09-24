//
//  AddPlayerView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Add Player view for creating new players - Short sheet format
/// Part of B-007 Player & Team Management implementation
struct AddPlayerView: View {
    let viewModel: PlayersViewModel
    
    // MARK: - State Management
    @State private var name = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and buttons
            HStack {
                // Close button
                Button(action: {
                    print("❌ AddPlayerView: User cancelled adding player")
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
                Text("Add player")
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
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Text input field
            TextField("Add player name", text: $name)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
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
        print("💾 AddPlayerView: Saving new player")
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            alertMessage = "Player name cannot be empty"
            showingAlert = true
            return
        }
        
        let newPlayer = Player(
            name: trimmedName,
            photo: nil,
            notes: "" // Simplified UI - no notes field
        )
        
        viewModel.addPlayer(newPlayer)
        print("✅ AddPlayerView: Player saved successfully")
        dismiss()
    }
}


// MARK: - Preview
#Preview {
    AddPlayerView(viewModel: PlayersViewModel())
}

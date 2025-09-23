//
//  MatchSetupView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Match Setup view (S-003)
/// F-002: Pick Player/Team A and B, target points, best-of sets, toggle for deuce
/// Error handling: block start if required fields are empty
struct MatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddMatchViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let mode: MatchSetupMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Image(systemName: mode == .liveMatch ? "play.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(mode == .liveMatch ? .green : .blue)
                        
                        Text(mode.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(mode.subtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Match Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        
                        
                        Picker("Match Type", selection: $viewModel.matchType) {
                            Text("Singles").tag(MatchType.singles)
                            Text("Doubles").tag(MatchType.doubles)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: viewModel.matchType) { _, _ in
                            viewModel.setMatchType(viewModel.matchType)
                        }
                    }
                    
                    // MARK: - Participant Selection
                    if viewModel.matchType == .singles {
                        SinglesParticipantSelection(viewModel: viewModel)
                    } else {
                        DoublesParticipantSelection(viewModel: viewModel)
                    }
                    
                    // MARK: - Match Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Match Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Target Points
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Points per Set")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Stepper(value: $viewModel.targetPoints, in: 1...50) {
                                    Text("\(viewModel.targetPoints)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .frame(minWidth: 40)
                                }
                                .onChange(of: viewModel.targetPoints) { _, newValue in
                                    viewModel.setTargetPoints(newValue)
                                }
                                
                                Spacer()
                                
                                Text("points")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Best of Sets
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Best of Sets")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Stepper(value: $viewModel.bestOfSets, in: 1...7, step: 2) {
                                    Text("\(viewModel.bestOfSets)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .frame(minWidth: 40)
                                }
                                .onChange(of: viewModel.bestOfSets) { _, newValue in
                                    viewModel.setBestOfSets(newValue)
                                }
                                
                                Spacer()
                                
                                Text("sets")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Deuce Rule Toggle
                        Toggle("Deuce Rule (Win by 2)", isOn: $viewModel.isDeuceEnabled)
                            .onChange(of: viewModel.isDeuceEnabled) { _, _ in
                                viewModel.toggleDeuce()
                            }
                    }
                    
                    // MARK: - Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (Optional)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Add any notes about this match...", text: $viewModel.notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                            .onChange(of: viewModel.notes) { _, newValue in
                                viewModel.setNotes(newValue)
                            }
                    }
                    
                    // MARK: - Validation Errors
                    if !viewModel.validationErrors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.validationErrors, id: \.self) { error in
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // MARK: - Action Buttons
                    VStack(spacing: 12) {
                        // Start/Save Button
                        Button(action: handleStartAction) {
                            HStack {
                                Image(systemName: mode == .liveMatch ? "play.fill" : "checkmark.circle.fill")
                                Text(mode == .liveMatch ? "Start Live Match" : "Save Match")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canStartMatch ? (mode == .liveMatch ? Color.green : Color.blue) : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.canStartMatch)
                        
                        // Cancel Button
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Match Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Actions
    
    private func handleStartAction() {
        print("🎾 MatchSetupView: Handling start action for mode: \(mode)")
        
        guard viewModel.canStartMatch else {
            print("❌ MatchSetupView: Cannot start match - validation failed")
            return
        }
        
        if mode == .liveMatch {
            handleLiveMatchStart()
        } else {
            handleCompletedMatchSave()
        }
    }
    
    private func handleLiveMatchStart() {
        print("🎾 MatchSetupView: Starting live match")
        
        guard let (match, liveState) = viewModel.startLiveMatch() else {
            alertMessage = "Failed to start live match. Please try again."
            showingAlert = true
            return
        }
        
        // Save the match and live state
        viewModel.dataManager.addMatch(match)
        viewModel.dataManager.setLiveMatchState(liveState)
        
        // TODO: Navigate to live scoring screen (B-005)
        print("✅ MatchSetupView: Live match started successfully")
        dismiss()
    }
    
    private func handleCompletedMatchSave() {
        print("💾 MatchSetupView: Saving completed match")
        
        guard viewModel.saveCompletedMatch() != nil else {
            alertMessage = "Failed to save match. Please try again."
            showingAlert = true
            return
        }
        
        print("✅ MatchSetupView: Completed match saved successfully")
        dismiss()
    }
}

// MARK: - Singles Participant Selection
struct SinglesParticipantSelection: View {
    let viewModel: AddMatchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            
            VStack(spacing: 12) {
                // Player A Selection
                ParticipantPicker(
                    title: "Player A",
                    selectedId: viewModel.selectedPlayerAId,
                    participants: viewModel.availablePlayers,
                    onSelectionChanged: { viewModel.selectPlayerA($0) }
                )
                
                // Player B Selection
                ParticipantPicker(
                    title: "Player B",
                    selectedId: viewModel.selectedPlayerBId,
                    participants: viewModel.availablePlayers,
                    onSelectionChanged: { viewModel.selectPlayerB($0) }
                )
            }
        }
    }
}

// MARK: - Doubles Participant Selection
struct DoublesParticipantSelection: View {
    let viewModel: AddMatchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Teams")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Team A Selection
                ParticipantPicker(
                    title: "Team A",
                    selectedId: viewModel.selectedTeamAId,
                    participants: viewModel.availableTeams,
                    onSelectionChanged: { viewModel.selectTeamA($0) }
                )
                
                // Team B Selection
                ParticipantPicker(
                    title: "Team B",
                    selectedId: viewModel.selectedTeamBId,
                    participants: viewModel.availableTeams,
                    onSelectionChanged: { viewModel.selectTeamB($0) }
                )
            }
        }
    }
}

// MARK: - Participant Picker
struct ParticipantPicker: View {
    let title: String
    let selectedId: UUID?
    let participants: [any ParticipantSelectable]
    let onSelectionChanged: (UUID?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Menu {
                Button("None") {
                    onSelectionChanged(nil)
                }
                
                ForEach(participants, id: \.id) { participant in
                    Button(participant.displayName) {
                        onSelectionChanged(participant.id)
                    }
                }
            } label: {
                HStack {
                    Text(selectedParticipantName)
                        .foregroundColor(selectedId == nil ? .secondary : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var selectedParticipantName: String {
        guard let selectedId = selectedId else {
            return "Select \(title)"
        }
        
        return participants.first { $0.id == selectedId }?.displayName ?? "Unknown"
    }
}

// MARK: - Participant Selectable Protocol
protocol ParticipantSelectable {
    var id: UUID { get }
    var displayName: String { get }
}

extension Player: ParticipantSelectable {
    var displayName: String {
        return name
    }
}

extension Team: ParticipantSelectable {
    var displayName: String {
        return name ?? "Unnamed Team"
    }
}

// MARK: - Previews
#Preview("Live Match Setup") {
    MatchSetupView(mode: .liveMatch)
}

#Preview("Completed Match Setup") {
    MatchSetupView(mode: .completedMatch)
}

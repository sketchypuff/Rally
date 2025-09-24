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
    @State private var showingLiveScoring = false
    @State private var liveMatch: Match?
    @State private var liveState: LiveMatchState?
    
    let mode: MatchSetupMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    // VStack(spacing: 8) {
                    //     Image(systemName: mode == .liveMatch ? "play.circle.fill" : "checkmark.circle.fill")
                    //         .font(.system(size: 50))
                    //         .foregroundColor(mode == .liveMatch ? .green : .blue)
                        
                    //     Text(mode.title)
                    //         .font(.title2)
                    //         .fontWeight(.bold)
                        
                    //     Text(mode.subtitle)
                    //         .font(.body)
                    //         .foregroundColor(.secondary)
                    // }
                    // .padding(.top, 20)
                    
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
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add players")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if viewModel.matchType == .singles {
                            SinglesParticipantSelectionAddMatch(viewModel: viewModel)
                        } else {
                            DoublesParticipantSelectionAddMatch(viewModel: viewModel)
                        }
                    }
                    
                    // MARK: - Match Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Match settings")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 0) {
                            // Date picker
                            HStack {
                                Text("Date")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { viewModel.matchDate },
                                        set: { viewModel.matchDate = $0 }
                                    ),
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Points per set
                            MatchSettingRow(
                                title: "Points per set",
                                value: $viewModel.targetPoints,
                                placeholder: "Enter points",
                                keyboardType: .numberPad,
                                onValueChanged: { newValue in
                                    let clampedValue = max(1, min(50, newValue))
                                    if clampedValue != newValue {
                                        viewModel.targetPoints = clampedValue
                                    }
                                    viewModel.setTargetPoints(clampedValue)
                                }
                            )
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Number of sets
                            MatchSettingRow(
                                title: "Number of sets",
                                value: $viewModel.bestOfSets,
                                placeholder: "Enter sets",
                                keyboardType: .numberPad,
                                onValueChanged: { newValue in
                                    let clampedValue = max(1, min(7, newValue))
                                    let oddValue = clampedValue % 2 == 0 ? clampedValue + 1 : clampedValue
                                    let finalValue = min(7, oddValue)
                                    
                                    if finalValue != newValue {
                                        viewModel.bestOfSets = finalValue
                                    }
                                    viewModel.setBestOfSets(finalValue)
                                }
                            )
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Deuce toggle
                            HStack {
                                Text("Deuce")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $viewModel.isDeuceEnabled)
                                    .onChange(of: viewModel.isDeuceEnabled) { _, _ in
                                        viewModel.toggleDeuce()
                                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    
                    // MARK: - Notes Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter note", text: $viewModel.notes, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .lineLimit(3...3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .onChange(of: viewModel.notes) { _, newValue in
                                viewModel.setNotes(newValue)
                            }
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
                        
                    
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            // Text("Back")
                            //     .font(.system(size: 16))
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
            // Ensure match date is set to current date
            viewModel.matchDate = Date()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showingLiveScoring) {
            liveScoringCoverView
        }
    }
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var liveScoringCoverView: some View {
        if let match = liveMatch, let state = liveState {
            LiveScoringView(match: match, liveState: state)
        } else {
            // Fallback view if data is missing
            VStack {
                Text("Error: Missing match data")
                    .font(.headline)
                    .foregroundColor(.red)
                Button("Close") {
                    showingLiveScoring = false
                }
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    
    private func handleStartAction() {
        print("🎾 MatchSetupView: Handling start action for mode: \(mode)")
        print("🎾 MatchSetupView: canStartMatch = \(viewModel.canStartMatch)")
        
        guard viewModel.canStartMatch else {
            print("❌ MatchSetupView: Cannot start match - validation failed")
            print("❌ MatchSetupView: Validation errors: \(viewModel.validationErrors)")
            return
        }
        
        if mode == .liveMatch {
            print("🎾 MatchSetupView: Calling handleLiveMatchStart()")
            handleLiveMatchStart()
        } else {
            print("🎾 MatchSetupView: Calling handleCompletedMatchSave()")
            handleCompletedMatchSave()
        }
    }
    
    private func handleLiveMatchStart() {
        print("🎾 MatchSetupView: Starting live match")
        
        guard let (match, liveState) = viewModel.startLiveMatch() else {
            print("❌ MatchSetupView: Failed to create match and live state")
            alertMessage = "Failed to start live match. Please try again."
            showingAlert = true
            return
        }
        
        print("✅ MatchSetupView: Created match: \(match.id)")
        print("✅ MatchSetupView: Created live state for match: \(liveState.matchId)")
        
        // Save the match and live state
        viewModel.dataManager.addMatch(match)
        viewModel.dataManager.setLiveMatchState(liveState)
        
        // Set up live scoring navigation
        self.liveMatch = match
        self.liveState = liveState
        print("🎾 MatchSetupView: Set liveMatch and liveState properties")
        
        // Trigger the fullScreenCover
        DispatchQueue.main.async {
            self.showingLiveScoring = true
            print("🎾 MatchSetupView: Set showingLiveScoring = true")
        }
        
        print("✅ MatchSetupView: Live match started successfully")
    }
    
    private func handleCompletedMatchSave() {
        print("💾 MatchSetupView: Navigating to LogCompletedMatchView")
        // For completed match mode, we'll show the LogCompletedMatchView instead
        // This will be handled by the parent view
    }
}

// MARK: - Singles Participant Selection
struct SinglesParticipantSelectionAddMatch: View {
    let viewModel: AddMatchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Player A Selection
            PlayerSelectionRowAddMatch(
                title: "Player 1",
                selectedId: viewModel.selectedPlayerAId,
                participants: viewModel.availablePlayers,
                onSelectionChanged: { viewModel.selectPlayerA($0) }
            )
            
            Divider()
                .padding(.leading, 16)
            
            // Player B Selection
            PlayerSelectionRowAddMatch(
                title: "Player 2",
                selectedId: viewModel.selectedPlayerBId,
                participants: viewModel.availablePlayers,
                onSelectionChanged: { viewModel.selectPlayerB($0) }
            )
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Doubles Participant Selection
struct DoublesParticipantSelectionAddMatch: View {
    let viewModel: AddMatchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Team A Selection
            PlayerSelectionRowAddMatch(
                title: "Team 1",
                selectedId: viewModel.selectedTeamAId,
                participants: viewModel.availableTeams,
                onSelectionChanged: { viewModel.selectTeamA($0) }
            )
            
            Divider()
                .padding(.leading, 16)
            
            // Team B Selection
            PlayerSelectionRowAddMatch(
                title: "Team 2",
                selectedId: viewModel.selectedTeamBId,
                participants: viewModel.availableTeams,
                onSelectionChanged: { viewModel.selectTeamB($0) }
            )
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Match Setting Row
struct MatchSettingRow: View {
    let title: String
    @Binding var value: Int
    let placeholder: String
    let keyboardType: UIKeyboardType
    let onValueChanged: (Int) -> Void
    
    @State private var textValue: String = ""
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            TextField(placeholder, text: $textValue)
                .keyboardType(keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                .multilineTextAlignment(.trailing)
                .onChange(of: textValue) { _, newValue in
                    if let intValue = Int(newValue) {
                        onValueChanged(intValue)
                    }
                }
                .onAppear {
                    textValue = String(value)
                }
                .onChange(of: value) { _, newValue in
                    textValue = String(newValue)
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Player Selection Row
struct PlayerSelectionRowAddMatch: View {
    let title: String
    let selectedId: UUID?
    let participants: [any ParticipantSelectable]
    let onSelectionChanged: (UUID?) -> Void
    
    var body: some View {
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
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(selectedParticipantName)
                    .font(.body)
                    .foregroundColor(selectedId == nil ? .secondary : .primary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var selectedParticipantName: String {
        guard let selectedId = selectedId else {
            return "Select"
        }
        
        return participants.first { $0.id == selectedId }?.displayName ?? "Unknown"
    }
}

// MARK: - Participant Picker (Legacy)
struct ParticipantPickerAddMatch: View {
    let title: String
    let selectedId: UUID?
    let participants: [any ParticipantSelectable]
    let onSelectionChanged: (UUID?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .fontWeight(.regular)
            
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
                .background(Color(.systemBackground))
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

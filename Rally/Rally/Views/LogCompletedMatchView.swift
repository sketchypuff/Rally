//
//  LogCompletedMatchView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Log Completed Match view
/// F-002: Log completed match with date picker, player selection, sets management, and notes
/// Uses MVVM pattern with LogCompletedMatchViewModel
struct LogCompletedMatchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LogCompletedMatchViewModel()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Match Type Selection
                    Picker("Match Type", selection: $viewModel.matchType) {
                        Text("Singles").tag(MatchType.singles)
                        Text("Doubles").tag(MatchType.doubles)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: viewModel.matchType) { _, _ in
                        viewModel.setMatchType(viewModel.matchType)
                    }
                    
                    // MARK: - Participant Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add players")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if viewModel.matchType == .singles {
                            SinglesParticipantSelection(viewModel: viewModel)
                        } else {
                            DoublesParticipantSelection(viewModel: viewModel)
                        }
                    }
                    
                    // MARK: - Match Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Match settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 0) {
                            // Date picker
                            HStack {
                                Text("Date")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                DatePicker(
                                    "",
                                    selection: $viewModel.matchDate,
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
                            MatchSettingRowLog(
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
                            MatchSettingRowLog(
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
                    
                    // MARK: - Sets Section
                    LogSetsSection(viewModel: viewModel)
                    
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
                    VStack(spacing: 16) {
                        // Log Completed Match Button
                        Button(action: handleSaveMatch) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text("Log Completed Match")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.canSaveMatch ? Color.blue : Color.gray)
                            )
                            .shadow(color: viewModel.canSaveMatch ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!viewModel.canSaveMatch)
                        .scaleEffect(viewModel.canSaveMatch ? 1.0 : 0.95)
                        .animation(.easeInOut(duration: 0.1), value: viewModel.canSaveMatch)
                        
                        // Validation errors display
                        if !viewModel.validationErrors.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.validationErrors, id: \.self) { error in
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
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
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Log Completed Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
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
    }
    
    // MARK: - Actions
    
    private func handleSaveMatch() {
        print("💾 LogCompletedMatchView: Logging completed match")
        
        guard viewModel.canSaveMatch else {
            print("❌ LogCompletedMatchView: Cannot log match - validation failed")
            return
        }
        
        guard viewModel.saveCompletedMatch() != nil else {
            alertMessage = "Failed to log match. Please try again."
            showingAlert = true
            return
        }
        
        print("✅ LogCompletedMatchView: Completed match logged successfully")
        dismiss()
    }
}

// MARK: - Singles Participant Selection
struct SinglesParticipantSelection: View {
    let viewModel: LogCompletedMatchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Player A Selection
            PlayerSelectionRow(
                title: "Player 1",
                selectedId: viewModel.selectedPlayerAId,
                participants: viewModel.availablePlayers,
                onSelectionChanged: { viewModel.selectPlayerA($0) }
            )
            
            Divider()
                .padding(.leading, 16)
            
            // Player B Selection
            PlayerSelectionRow(
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
struct DoublesParticipantSelection: View {
    let viewModel: LogCompletedMatchViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Team A Selection
            PlayerSelectionRow(
                title: "Team 1",
                selectedId: viewModel.selectedTeamAId,
                participants: viewModel.availableTeams,
                onSelectionChanged: { viewModel.selectTeamA($0) }
            )
            
            Divider()
                .padding(.leading, 16)
            
            // Team B Selection
            PlayerSelectionRow(
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
struct MatchSettingRowLog: View {
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
struct PlayerSelectionRow: View {
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

// MARK: - Participant Picker (Legacy - keeping for MatchSetupView compatibility)
struct ParticipantPicker: View {
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

// MARK: - Log Sets Section
struct LogSetsSection: View {
    let viewModel: LogCompletedMatchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sets")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // MARK: - Sets Grid
            VStack(spacing: 0) {
                // Player Headers
                HStack(spacing: 0) {
                    // Player A Header
                    Text(viewModel.getPlayerAName())
                        .font(.headline)
                       
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 8) // Add spacing between columns
                    
                    // Player B Header
                    Text(viewModel.getPlayerBName())
                        .font(.headline)
                       
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8) // Add spacing between columns
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Sets Rows in List for proper swipe actions
                List {
                    ForEach(Array(viewModel.setScores.enumerated()), id: \.offset) { index, setScore in
                        LogSetRow(
                            setNumber: index + 1,
                            setScore: setScore,
                            onPlayerAPointsChanged: { newPoints in
                                viewModel.updateSetScore(at: index, playerAPoints: newPoints, playerBPoints: setScore.playerBPoints)
                            },
                            onPlayerBPointsChanged: { newPoints in
                                viewModel.updateSetScore(at: index, playerAPoints: setScore.playerAPoints, playerBPoints: newPoints)
                            },
                            onRemoveSet: {
                                print("➖ LogSetsSection: Remove set \(index + 1)")
                                viewModel.removeSet(at: index)
                            },
                            canRemove: viewModel.setScores.count > 1,
                            isLastRow: index == viewModel.setScores.count - 1 // Pass isLastRow parameter
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(max(3, viewModel.setScores.count) * 70)) // Fixed height for 3 sets minimum, compact spacing
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Log Set Row
struct LogSetRow: View {
    let setNumber: Int
    let setScore: SetScore
    let onPlayerAPointsChanged: (Int) -> Void
    let onPlayerBPointsChanged: (Int) -> Void
    let onRemoveSet: () -> Void
    let canRemove: Bool
    let isLastRow: Bool // Add parameter to identify last row
    
    @State private var playerAPointsText: String = ""
    @State private var playerBPointsText: String = ""
    
    var body: some View {
        HStack(spacing: 16) { // Add spacing between columns
            // Player A Column
            VStack(spacing: 4) { // Reduced spacing for compact layout
                Text("Set \(setNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("0", text: $playerAPointsText)
                    .keyboardType(.numberPad) // Numerical keyboard
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 6) // Reduced padding for compact layout
                    .padding(.horizontal, 0)
                    .background(Color.clear)
                    .overlay(
                        // Only show bottom divider if not the last row
                        !isLastRow ? Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1) : nil,
                        alignment: .bottom
                    )
                    .onChange(of: playerAPointsText) { _, newValue in
                        if let points = Int(newValue), points >= 0 {
                            onPlayerAPointsChanged(points)
                        }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Player B Column
            VStack(spacing: 4) { // Reduced spacing for compact layout
                Text("Set \(setNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("0", text: $playerBPointsText)
                    .keyboardType(.numberPad) // Numerical keyboard
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 6) // Reduced padding for compact layout
                    .padding(.horizontal, 0)
                    .background(Color.clear)
                    .overlay(
                        // Only show bottom divider if not the last row
                        !isLastRow ? Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1) : nil,
                        alignment: .bottom
                    )
                    .onChange(of: playerBPointsText) { _, newValue in
                        if let points = Int(newValue), points >= 0 {
                            onPlayerBPointsChanged(points)
                        }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8) // Reduced vertical padding for compact layout
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if canRemove {
                Button(action: onRemoveSet) {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .onAppear {
            playerAPointsText = String(setScore.playerAPoints)
            playerBPointsText = String(setScore.playerBPoints)
        }
        .onChange(of: setScore.playerAPoints) { _, newValue in
            playerAPointsText = String(newValue)
        }
        .onChange(of: setScore.playerBPoints) { _, newValue in
            playerBPointsText = String(newValue)
        }
    }
}

// MARK: - Previews
#Preview("Log Completed Match") {
    LogCompletedMatchView()
}

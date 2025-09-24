//
//  LiveScoringView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Live Scoring view (S-004)
/// F-003: Shows both sides' points with big + / − buttons, Advance to Next Set, Pause/Save, and Undo history
/// F-009: Undo / History in Live Match with undo last point(s) and show short history
/// Error handling: if save fails, show short message and keep running
struct LiveScoringView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LiveScoringViewModel
    @State private var showingSaveConfirmation = false
    @State private var showingUndoHistory = false
    
    init(match: Match, liveState: LiveMatchState) {
        self._viewModel = State(initialValue: LiveScoringViewModel(match: match, liveState: liveState))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Header
                headerView
                
                // MARK: - Match Info
                matchInfoView
                
                // MARK: - Completed Sets
                if !viewModel.completedSets.isEmpty {
                    completedSetsView
                }
                
                // MARK: - Current Set Score
                currentSetScoreView
                
                // MARK: - Scoring Buttons
                scoringButtonsView
                
                // MARK: - Action Buttons
                actionButtonsView
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Live Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if viewModel.isMatchCompleted {
                            dismiss()
                        } else {
                            showingSaveConfirmation = true
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back")
                                .font(.system(size: 16))
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingUndoHistory = true
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .disabled(!viewModel.canUndo)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .confirmationDialog("Save Match", isPresented: $showingSaveConfirmation) {
            Button("Save & Exit") {
                viewModel.saveMatch()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to save the current match and exit?")
        }
        .sheet(isPresented: $showingUndoHistory) {
            UndoHistoryView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.playerAName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.matchTypeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.formattedDuration)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Set \(viewModel.currentSetNumber) of \(viewModel.bestOfSets)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if viewModel.isPaused {
                    HStack(spacing: 4) {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(.orange)
                        Text("Paused")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Match Info View
    private var matchInfoView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Target: \(viewModel.targetPoints) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if viewModel.isDeuceEnabled {
                    Text("Deuce: Win by 2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Completed Sets View
    private var completedSetsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Completed Sets")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.completedSets.enumerated()), id: \.offset) { index, setScore in
                        VStack(spacing: 4) {
                            Text("Set \(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(setScore.playerAPoints)-\(setScore.playerBPoints)")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Current Set Score View
    private var currentSetScoreView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Player A Score
                VStack(spacing: 8) {
                    Text(viewModel.playerAName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.currentSetScore.playerAPoints)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                // VS Separator
                Text("VS")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                // Player B Score
                VStack(spacing: 8) {
                    Text(viewModel.playerBName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.currentSetScore.playerBPoints)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Set completion indicator
            if viewModel.isCurrentSetCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Set Completed!")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Scoring Buttons View
    private var scoringButtonsView: some View {
        VStack(spacing: 16) {
            // Player A Controls
            HStack(spacing: 16) {
                // Minus Button
                Button(action: {
                    viewModel.removePointFromPlayerA()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                }
                .disabled(viewModel.currentSetScore.playerAPoints == 0 || viewModel.isMatchCompleted)
                
                Spacer()
                
                // Plus Button
                Button(action: {
                    viewModel.addPointToPlayerA()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                }
                .disabled(viewModel.isMatchCompleted)
            }
            .padding(.horizontal, 40)
            
            // Player B Controls
            HStack(spacing: 16) {
                // Minus Button
                Button(action: {
                    viewModel.removePointFromPlayerB()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                }
                .disabled(viewModel.currentSetScore.playerBPoints == 0 || viewModel.isMatchCompleted)
                
                Spacer()
                
                // Plus Button
                Button(action: {
                    viewModel.addPointToPlayerB()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                }
                .disabled(viewModel.isMatchCompleted)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            // Advance Set Button
            if viewModel.isCurrentSetCompleted && !viewModel.isMatchCompleted {
                Button(action: {
                    viewModel.advanceToNextSet()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Advance to Next Set")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }
            
            // Pause/Resume and Save Buttons
            HStack(spacing: 12) {
                // Pause/Resume Button
                Button(action: {
                    if viewModel.isPaused {
                        viewModel.resumeMatch()
                    } else {
                        viewModel.pauseMatch()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        Text(viewModel.isPaused ? "Resume" : "Pause")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isPaused ? Color.green : Color.orange)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isMatchCompleted)
                
                // Save Button
                Button(action: {
                    showingSaveConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            
            // Undo Button
            if viewModel.canUndo {
                Button(action: {
                    viewModel.undoLastAction()
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                        Text("Undo Last Action")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Undo History View
struct UndoHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: LiveScoringViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(viewModel.liveState.undoHistory.enumerated().reversed()), id: \.offset) { index, action in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(action.actionType.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Set \(action.setNumber): \(action.previousScore.playerAPoints)-\(action.previousScore.playerBPoints)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(action.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Undo History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Live Scoring") {
    LiveScoringView(
        match: Match.sampleMatches[0],
        liveState: LiveMatchState.sampleState
    )
}

#Preview("Completed Set") {
    var liveState = LiveMatchState.sampleState
    liveState.completedSets = [
        SetScore(playerAPoints: 21, playerBPoints: 19),
        SetScore(playerAPoints: 18, playerBPoints: 21)
    ]
    liveState.currentSetPoints = SetScore(playerAPoints: 15, playerBPoints: 10)
    
    return LiveScoringView(
        match: Match.sampleMatches[0],
        liveState: liveState
    )
}

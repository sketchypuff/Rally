//
//  MatchCardView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Individual match card view
/// Shows match details: date, opponent/team, W/L result, and score
/// Uses MVVM pattern with MatchListViewModel
struct MatchCardView: View {
    let match: Match
    let viewModel: MatchListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Match Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.getFormattedDate(for: match))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.getMatchTypeString(for: match))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // MARK: - Match Result Badge
                MatchResultBadge(result: match.result)
            }
            
            // MARK: - Participants
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("You")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("vs")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.6))
                    Text(viewModel.getOpponentName(for: match))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // MARK: - Score Display
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.getFormattedScore(for: match))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // MARK: - Match Notes (if any)
            if !match.notes.isEmpty {
                Text(match.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            viewModel.selectMatch(match)
        }
    }
}

/// Match result badge component
/// Shows colored badge for match result (Won/Lost/In Progress)
struct MatchResultBadge: View {
    let result: MatchResult
    
    var body: some View {
        Text(result.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch result {
        case .won:
            return .green.opacity(0.2)
        case .lost:
            return .red.opacity(0.2)
        case .inProgress:
            return .blue.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch result {
        case .won:
            return .green
        case .lost:
            return .red
        case .inProgress:
            return .blue
        }
    }
}

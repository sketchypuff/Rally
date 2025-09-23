//
//  AddMatchMenuView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Add Match Menu view (S-002)
/// F-002: Menu with choices: Start Live Match or Log Completed Match
struct AddMatchMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingMatchSetup = false
    @State private var matchSetupMode: MatchSetupMode = .liveMatch
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Menu Options
            VStack(spacing: 16) {
                // Start Live Match Button
                MenuOptionButton(
                    title: "Start live match",
                    subtitle: "Enter scores as you play",
                    icon: "play.circle.fill",
                    color: .green
                ) {
                    matchSetupMode = .liveMatch
                    showingMatchSetup = true
                }
                
                // Log Completed Match Button
                MenuOptionButton(
                    title: "Log completed match",
                    subtitle: "Enter scores manually",
                    icon: "checkmark.circle.fill",
                    color: .blue
                ) {
                    matchSetupMode = .completedMatch
                    showingMatchSetup = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .sheet(isPresented: $showingMatchSetup) {
            MatchSetupView(mode: matchSetupMode)
        }
    }
}

// MARK: - Menu Option Button
struct MenuOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(color)
                    .clipShape(Circle())
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Match Setup Mode
enum MatchSetupMode {
    case liveMatch
    case completedMatch
    
    var title: String {
        switch self {
        case .liveMatch:
            return "Start Live Match"
        case .completedMatch:
            return "Log Completed Match"
        }
    }
    
    var subtitle: String {
        switch self {
        case .liveMatch:
            return "Score as you play"
        case .completedMatch:
            return "Enter scores manually"
        }
    }
}

// MARK: - Previews
#Preview("Add Match Menu") {
    AddMatchMenuView()
}

#Preview("Menu Option Button") {
    VStack(spacing: 16) {
        MenuOptionButton(
            title: "Start Live Match",
            subtitle: "Score as you play",
            icon: "play.circle.fill",
            color: .green
        ) {
            print("Start Live Match tapped")
        }
        
        MenuOptionButton(
            title: "Log Completed Match",
            subtitle: "Enter scores manually",
            icon: "checkmark.circle.fill",
            color: .blue
        ) {
            print("Log Completed Match tapped")
        }
    }
    .padding()
}

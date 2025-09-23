//
//  SettingsView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Settings view - placeholder for S-008
/// Uses MVVM pattern with SettingsViewModel
struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "gear")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Coming in B-010")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding(.top)
                }
                
                // Show some basic stats from the ViewModel
                VStack(spacing: 8) {
                    Text("Total Matches: \(viewModel.totalMatches)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Total Players: \(viewModel.totalPlayers)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Total Teams: \(viewModel.totalTeams)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
            }
            .navigationTitle("Settings")
        }
    }
}

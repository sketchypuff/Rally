//
//  PlayersView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Players management view - placeholder for S-006
/// Uses MVVM pattern with PlayersViewModel
struct PlayersView: View {
    @State private var viewModel = PlayersViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Players & Teams")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Coming in B-007")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding(.top)
                }
            }
            .navigationTitle("Players")
            .onAppear {
                viewModel.refreshData()
            }
        }
    }
}

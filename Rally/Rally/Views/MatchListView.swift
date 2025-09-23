//
//  MatchListView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Match List View - Main content of the home tab
/// Shows all matches in a list with cards for each match
/// Uses MVVM pattern with MatchListViewModel
struct MatchListView: View {
    @State private var viewModel = MatchListViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isEmpty {
                    // MARK: - Empty State
                    EmptyMatchesView(showingAddMatch: $viewModel.showingAddMatch)
                } else {
                    // MARK: - Match List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.sortedMatches) { match in
                                MatchCardView(match: match, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Your matches")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showAddMatch()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddMatch) {
                AddMatchView()
            }
            .onAppear {
                viewModel.refreshMatches()
            }
        }
    }
}

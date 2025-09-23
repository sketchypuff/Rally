//
//  AnalyticsView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Analytics view - placeholder for S-007
/// Uses MVVM pattern with AnalyticsViewModel
struct AnalyticsView: View {
    @State private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Analytics")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Coming in B-009")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding(.top)
                } else if !viewModel.hasEnoughData {
                    Text("Not enough data yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
            }
            .navigationTitle("Stats")
            .onAppear {
                viewModel.refreshData()
            }
        }
    }
}

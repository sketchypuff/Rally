//
//  EmptyMatchesView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Empty state view when no matches exist
/// Shows "No matches yet" message and big "Start match" button
struct EmptyMatchesView: View {
    @Binding var showingAddMatch: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // MARK: - Empty State Icon
            Image(systemName: "badminton.racket")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            // MARK: - Empty State Text
            VStack(spacing: 8) {
                Text("No matches yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Start your first badminton match to begin tracking your progress")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // MARK: - Start Match Button
            Button(action: {
                print("🎾 EmptyMatchesView: Start match button tapped")
                showingAddMatch = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Start Match")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

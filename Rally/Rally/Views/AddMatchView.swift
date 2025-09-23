//
//  AddMatchView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Add Match view - placeholder for S-002, S-003
struct AddMatchView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Add Match")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Coming in B-004")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Match")
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

//
//  AddMatchView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Add Match view - Main entry point for S-002, S-003
/// F-002: Add Match / Start Match Flow with menu and setup
/// Uses AddMatchMenuView as the main interface
struct AddMatchView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        AddMatchMenuView()
    }
}

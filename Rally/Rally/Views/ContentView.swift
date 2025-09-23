//
//  ContentView.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import SwiftUI

/// Main screen (S-001) - Match List with bottom navigation
/// F-001: Shows all saved matches in a list (newest first), appears on app launch
/// Error handling: if no matches, show "No matches yet" and a big "Start match" button
/// Uses MVVM pattern with individual ViewModels for each tab
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Home Tab (Match List)
            MatchListView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Matches")
                }
                .tag(0)
            
            // MARK: - Players Tab
            PlayersView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Players")
                }
                .tag(1)
            
            // MARK: - Analytics Tab
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(2)
            
            // MARK: - Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
    }
}

#Preview("Empty State") {
    ContentView()
}

#Preview("With Matches") {
    ContentView()
}

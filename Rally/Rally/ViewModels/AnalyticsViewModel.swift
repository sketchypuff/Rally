//
//  AnalyticsViewModel.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation
import SwiftUI

/// ViewModel for Analytics and Statistics
/// Handles business logic for match analytics and statistics
/// Follows MVVM pattern by separating view logic from data management
@Observable
final class AnalyticsViewModel {
    // MARK: - Dependencies
    private let dataManager: DataManager
    
    // MARK: - Published Properties
    var matches: [Match] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Check if there are enough matches for analytics
    var hasEnoughData: Bool {
        return matches.count >= 2
    }
    
    /// Get total number of matches
    var totalMatches: Int {
        return matches.count
    }
    
    /// Get completed matches only
    var completedMatches: [Match] {
        return matches.filter { $0.isCompleted }
    }
    
    /// Get win rate percentage
    var winRate: Double {
        let completed = completedMatches
        guard !completed.isEmpty else { return 0.0 }
        
        let wins = completed.filter { $0.result == .won }.count
        return Double(wins) / Double(completed.count) * 100
    }
    
    /// Get win count
    var winCount: Int {
        return completedMatches.filter { $0.result == .won }.count
    }
    
    /// Get loss count
    var lossCount: Int {
        return completedMatches.filter { $0.result == .lost }.count
    }
    
    /// Get matches by month for trends
    var matchesByMonth: [String: Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        var result: [String: Int] = [:]
        for match in completedMatches {
            let monthKey = formatter.string(from: match.date)
            result[monthKey, default: 0] += 1
        }
        return result
    }
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        print("🏗️ AnalyticsViewModel: Initializing with DataManager")
        loadData()
    }
    
    // MARK: - Data Loading
    
    /// Load matches from DataManager
    private func loadData() {
        print("🔄 AnalyticsViewModel: Loading matches from DataManager")
        isLoading = true
        errorMessage = nil
        
        // Simulate async loading for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.matches = self.dataManager.matches
            self.isLoading = false
            print("✅ AnalyticsViewModel: Loaded \(self.matches.count) matches for analytics")
        }
    }
    
    /// Refresh data from DataManager
    func refreshData() {
        print("🔄 AnalyticsViewModel: Refreshing data")
        loadData()
    }
    
    // MARK: - Analytics Methods
    
    /// Get win rate for a specific time period
    func getWinRate(for period: TimePeriod) -> Double {
        let filteredMatches = getMatches(for: period)
        guard !filteredMatches.isEmpty else { return 0.0 }
        
        let wins = filteredMatches.filter { $0.result == .won }.count
        return Double(wins) / Double(filteredMatches.count) * 100
    }
    
    /// Get matches for a specific time period
    func getMatches(for period: TimePeriod) -> [Match] {
        let now = Date()
        let calendar = Calendar.current
        
        let startDate: Date
        switch period {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .all:
            return completedMatches
        }
        
        return completedMatches.filter { $0.date >= startDate }
    }
    
    /// Get match trends over time
    func getMatchTrends() -> [MatchTrend] {
        let matches = completedMatches.sorted { $0.date < $1.date }
        var trends: [MatchTrend] = []
        
        for (index, match) in matches.enumerated() {
            let isWin = match.result == .won
            trends.append(MatchTrend(
                date: match.date,
                isWin: isWin,
                matchNumber: index + 1
            ))
        }
        
        return trends
    }
    
    /// Get head-to-head statistics
    func getHeadToHeadStats() -> [String: HeadToHeadStats] {
        var stats: [String: HeadToHeadStats] = [:]
        
        for match in completedMatches {
            let opponent = getOpponentName(for: match)
            if stats[opponent] == nil {
                stats[opponent] = HeadToHeadStats(opponent: opponent)
            }
            
            if match.result == .won {
                stats[opponent]?.wins += 1
            } else {
                stats[opponent]?.losses += 1
            }
        }
        
        return stats
    }
    
    // MARK: - Helper Methods
    
    /// Get opponent name for a match
    private func getOpponentName(for match: Match) -> String {
        // TODO: Implement when we have player/team data loaded
        if match.type == .singles {
            return "Opponent"
        } else {
            return "Opponent Team"
        }
    }
}

// MARK: - Supporting Types

/// Time period for analytics filtering
enum TimePeriod: String, CaseIterable {
    case week = "week"
    case month = "month"
    case year = "year"
    case all = "all"
    
    var displayName: String {
        return rawValue.capitalized
    }
}

/// Match trend data for charts
struct MatchTrend: Identifiable {
    let id = UUID()
    let date: Date
    let isWin: Bool
    let matchNumber: Int
}

/// Head-to-head statistics
struct HeadToHeadStats {
    let opponent: String
    var wins: Int = 0
    var losses: Int = 0
    
    var totalMatches: Int {
        return wins + losses
    }
    
    var winRate: Double {
        guard totalMatches > 0 else { return 0.0 }
        return Double(wins) / Double(totalMatches) * 100
    }
}

// MARK: - Preview Support
extension AnalyticsViewModel {
    /// Create a preview instance with sample data
    static func preview() -> AnalyticsViewModel {
        let viewModel = AnalyticsViewModel()
        viewModel.matches = Match.sampleMatches
        return viewModel
    }
}

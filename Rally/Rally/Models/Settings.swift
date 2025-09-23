//
//  Settings.swift
//  Rally
//
//  Created by Yash Shenai on 23/09/25.
//

import Foundation

/// Settings data model for app configuration
/// D-004: Settings with default target points, best-of, last used settings
struct Settings: Codable {
    var defaultTargetPoints: Int
    var defaultBestOfSets: Int
    var enableDeuceRule: Bool
    var lastUsedTargetPoints: Int
    var lastUsedBestOfSets: Int
    var lastUsedMatchType: MatchType?
    
    init(
        defaultTargetPoints: Int = 21,
        defaultBestOfSets: Int = 3,
        enableDeuceRule: Bool = true,
        lastUsedTargetPoints: Int = 21,
        lastUsedBestOfSets: Int = 3,
        lastUsedMatchType: MatchType? = nil
    ) {
        self.defaultTargetPoints = defaultTargetPoints
        self.defaultBestOfSets = defaultBestOfSets
        self.enableDeuceRule = enableDeuceRule
        self.lastUsedTargetPoints = lastUsedTargetPoints
        self.lastUsedBestOfSets = lastUsedBestOfSets
        self.lastUsedMatchType = lastUsedMatchType
    }
    
    /// Debug helper for logging settings
    var debugDescription: String {
        return "Settings(defaultTarget: \(defaultTargetPoints), defaultBestOf: \(defaultBestOfSets), deuce: \(enableDeuceRule))"
    }
    
    /// Validate settings values
    var isValid: Bool {
        return defaultTargetPoints > 0 && 
               defaultBestOfSets > 0 && 
               defaultBestOfSets % 2 == 1 && // Must be odd
               lastUsedTargetPoints > 0 && 
               lastUsedBestOfSets > 0 && 
               lastUsedBestOfSets % 2 == 1 // Must be odd
    }
}

// MARK: - Default Settings
extension Settings {
    static let `default` = Settings()
}

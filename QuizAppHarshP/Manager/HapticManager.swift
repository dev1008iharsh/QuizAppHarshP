//
//  HapticManager.swift
//  QuizAppHarshP
//
//  Created by Harsh on 26/01/26.
//

import UIKit

/// A dedicated manager to handle Light and Heavy haptic feedbacks.
final class HapticManager {
    
    // MARK: - Singleton
     static let shared = HapticManager()
    
     private init() {}
    
    // MARK: - Haptic Actions
    
     func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare() // Reduces latency (Lag ઓછો કરે)
        generator.impactOccurred()
    }
    
     func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
}

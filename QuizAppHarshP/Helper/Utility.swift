//
//  UIKit.swift
//  HarshDemoPractical
//
//  Created by My Mac Mini on 09/02/24.
//

 
import UIKit
 

class Utility {
    static let shared = Utility()
    private init() {}
 
    func heavyHapticFeedBack(){
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavyImpact)
        feedbackGenerator.impact()
    }
 
    
    func lightHapticFeedBack(){
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .lightImpact)
        feedbackGenerator.impact()
    }
    
}

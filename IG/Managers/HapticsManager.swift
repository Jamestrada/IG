//
//  HapticsManager.swift
//  IG
//
//  Created by James Estrada on 7/25/21.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() {
        
    }
    
    func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

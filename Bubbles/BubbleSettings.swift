//
//  BubbleSettings.swift
//  bubbles
//
//  Created by Julian Jans on 12/09/2015.
//  Copyright © 2015 Julian Jans. All rights reserved.
//

import UIKit

class BubbleSettings {
    
    static func setStandardSettings() {
        let userDefaults = UserDefaults.standard
        if ((userDefaults.object(forKey: "bubble_quantity")) == nil) {
            userDefaults.set(0.8, forKey: "bubble_quantity")
        }
        if ((userDefaults.object(forKey: "bubble_longevity")) == nil) {
            userDefaults.set(0.7, forKey: "bubble_longevity")
        }
        if ((userDefaults.object(forKey: "background_transition")) == nil) {
            userDefaults.set(0.5, forKey: "background_transition")
        }
        if ((userDefaults.object(forKey: "character_visibility")) == nil) {
            userDefaults.set(0.0, forKey: "character_visibility")
        }
        if ((userDefaults.object(forKey: "hue_connection")) == nil) {
            userDefaults.set(true, forKey: "hue_connection")
        }
    }
    
    
    // MARK: Background Transition Speed
    
    static let maxTransition = 30.0
    static let minTransition = 2.0
    static var backgroundTransition: Double {
        get {
            let settings = UserDefaults.standard.double(forKey: "background_transition")
            return (((maxTransition - minTransition) * settings) + minTransition)
        }
    }
    
    
    // MARK: Bubble Quantity
    
    static let maxBubbles = 30
    static let minBubbles = 3
    static var quantity: Int {
        get {
            let settings = UserDefaults.standard.float(forKey: "bubble_quantity")
            return (Int(Float(maxBubbles - minBubbles) * settings) + minBubbles)
        }
    }
    
    
    // MARK: Bubble Lifespan
    
    static let maxLongevity = 30.0
    static let minLongevity = 2.0
    static var longevity: Double {
        get {
            let settings = UserDefaults.standard.double(forKey: "bubble_longevity")
            return (((maxLongevity - minLongevity) * settings) + minLongevity)
        }
    }

    
    // MARK: Character Visibility
    
    static let maxCharacterVisibility = 1.0
    static let minCharacterVisibility = -1.0
    static var characterVisibility: Double {
        get {
            let settings = UserDefaults.standard.double(forKey: "character_visibility")
            return (((maxCharacterVisibility - minCharacterVisibility) * settings) + minCharacterVisibility)
        }
    }

    
    // MARK: Lighting Effects
    
    static var hueConnection: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hue_connection")
        }
        set(bool) {
            UserDefaults.standard.set(bool, forKey:"hue_connection")
        }
    }
}

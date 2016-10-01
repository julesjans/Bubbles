//
//  BubbleLights.swift
//  bubbles
//
//  Created by Julian Jans on 02/12/2015.
//  Copyright © 2015 Julian Jans. All rights reserved.
//

import UIKit
import HomeKit


class BubbleLights : NSObject, HMHomeManagerDelegate {
    
    var manager : HMHomeManager?
    var lights : [HMService]?
    
    override init() {
        super.init()
        manager = HMHomeManager()
        manager!.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        lights = manager.primaryHome?.servicesWithTypes([HMServiceTypeLightbulb])
    }
    
    func colorLights(_ color: UIColor) {
        
        if (lights == nil || !BubbleSettings.hueConnection) {
            return
        }
      
        DispatchQueue.global().async(execute: {
 
            var hue :CGFloat = 0.0
            var saturation :CGFloat = 0.0
            var brightness :CGFloat = 0.0
            var alpha :CGFloat = 0.0
            
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            
            let destinationHue :CGFloat = hue*360
            let destinationSaturation :CGFloat = saturation*100.0
            let destinationBrightness :CGFloat = brightness*100.0

            for light in self.lights! {

                for characteristic in light.characteristics {
                    
                    switch characteristic.characteristicType {
                        
                    case HMCharacteristicTypePowerState:
                        characteristic.writeValue(true, completionHandler: {
                            error in
                            if let error = error {
                                NSLog("Failed switching on:\(error)")
                            }
                        })
                        
                    case HMCharacteristicTypeBrightness:
                        characteristic.writeValue(destinationBrightness, completionHandler: {
                            error in
                            if let error = error {
                                NSLog("Failed updating brightness:\(error)")
                            }
                        })
                    case HMCharacteristicTypeSaturation:
                        characteristic.writeValue(destinationSaturation, completionHandler: {
                            error in
                            if let error = error {
                                NSLog("Failed updating saturation:\(error)")
                            }
                        })
                    case HMCharacteristicTypeHue:
                        characteristic.writeValue(destinationHue, completionHandler: {
                            error in
                            if let error = error {
                                NSLog("Failed updating hue:\(error)")
                            }
                        })
                    default:
                        break
                    }
                }
            }
        })
    }
    
    func resetLights() {
        if let actionSets = manager!.primaryHome?.actionSets {
            for actionSet in actionSets {
                if (actionSet.name == "Standard Lights") {
                    manager!.primaryHome!.executeActionSet(actionSet, completionHandler: {
                        error in
                        if let error = error {
                            NSLog("Failed resetting lights:\(error)")
                        }
                    })
                }
            }
        }
    }
}





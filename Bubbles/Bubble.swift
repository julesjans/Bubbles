//
//  Bubble.swift
//  bubbles
//
//  Created by Julian Jans on 08/09/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

import UIKit
import AVFoundation

enum BubbleSounds {
    case create, pop
}

protocol BubbleControllerDelegate {
    func moveBubble(_ bubble: Bubble, pan: UIPanGestureRecognizer)
}

@IBDesignable
class Bubble: UIView {
    
    var bubbleDelegate: BubbleControllerDelegate?
    lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(Bubble.moveBubble))
    
    var audioPlayer = AVAudioPlayer()

    @IBInspectable var bubbleColour:UIColor?
    @IBInspectable var bubbleFont:UIFont?
    @IBInspectable var bubbleCharacter:NSString?
    
    var dynamicBehaviour: UIDynamicItemBehavior?
    var attachment: UIAttachmentBehavior?
    var collision: UICollisionBehavior?
    
    init(frame: CGRect, colour: UIColor) {
        super.init(frame: frame)
        self.bubbleColour = colour
        self.addGestureRecognizer(panGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let circle:UIBezierPath = UIBezierPath(ovalIn: bounds)
        if let colour = bubbleColour {
            colour.setFill()
        }
        circle.fill()

        if ((self.bubbleCharacter) != nil) {
            
            // TODO: Need to implement a slider to mask or hide the letters
            
            let visibility = CGFloat(BubbleSettings.characterVisibility)
            
            let fieldColor: UIColor = bubbleColour!.adjust(visibility, green: visibility, blue: visibility, alpha: visibility)
            let fieldFont = (self.bubbleFont != nil) ? self.bubbleFont!.withSize(self.bounds.height/2.0) : UIFont.systemFont(ofSize: self.bounds.height/2.0)
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.alignment = NSTextAlignment.center
            
            let attributes: Dictionary = [
                NSAttributedStringKey.foregroundColor: fieldColor,
                NSAttributedStringKey.font: fieldFont,
                NSAttributedStringKey.paragraphStyle: paraStyle
            ]
            
            // let height = self.bubbleCharacter?.boundingRectWithSize(self.bounds.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil).height
            let height = self.bubbleCharacter?.size(withAttributes: attributes).height
            let yOffset = ((self.bounds.height - height!) / 2.0)
            var textFrame = self.bounds
            textFrame.origin.y = yOffset
        
            self.bubbleCharacter?.draw(in: textFrame, withAttributes: attributes)
        }
    }
    
    func playSound(_ sound: BubbleSounds) {
        DispatchQueue.global().async(execute: {
            var bubbleSound: URL
            switch sound {
            case BubbleSounds.create:
                bubbleSound = URL(fileURLWithPath: (Bundle.main.path(forResource: "Bubble", ofType: "wav"))!)
                self.audioPlayer = try! AVAudioPlayer(contentsOf: bubbleSound)
                self.audioPlayer.volume = 1.0
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
            case BubbleSounds.pop:
                bubbleSound = URL(fileURLWithPath: (Bundle.main.path(forResource: "Pop", ofType: "wav"))!)
                // self.audioPlayer = try! AVAudioPlayer(contentsOfURL: bubbleSound)
                // self.audioPlayer.volume = 0.05
                // self.audioPlayer.prepareToPlay()
                // self.audioPlayer.play()
            }
        })
    }
    
    @objc func moveBubble() {
        self.bubbleDelegate?.moveBubble(self, pan: self.panGesture)
    }
}


extension UIColor{
    func adjust(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor{
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
}


//
//  ViewController.swift
//  bubbles
//
//  Created by Julian Jans on 08/09/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion


// TODO: Recursive function to capture overlapping words...


class BubbleController: UIViewController, UICollisionBehaviorDelegate, BubbleControllerDelegate {
    
    var animator:UIDynamicAnimator?
    let motionManager = CMMotionManager()
    let gravity = UIGravityBehavior()
    var currentRotation: CGFloat?
    let bubbleLights = BubbleLights()
    
    let fonts = ["Courier", "Georgia", "Chalkboard SE", "Georgia", "Helvetica", "Cochin", "Palatino"]
    let characters: NSString = "abcdefghijklmnopqrstuvyxyzaeiouABCDEFGHIJKLMNOPQRSTUVYXYZAEIOUAEIOUAEIOU"
    
    @IBOutlet var bubbles:[Bubble] = []
    @IBOutlet var panGesture:UIPanGestureRecognizer!
    
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: self.view)
        animator?.addBehavior(gravity)
    
        self.animateBackground()
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BubbleController.clearBubbles), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BubbleController.clearLights), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {
                (motion, error) in
                let grav : CMAcceleration = motion!.gravity;
                let x = CGFloat(grav.x);
                let y = CGFloat(grav.y);
                let v = CGVector(dx: -x, dy: -(0 - y));
                self.gravity.gravityDirection = v;
                self.currentRotation = CGFloat(atan2(motion!.gravity.x, motion!.gravity.y) - .pi)
            }
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    // MARK: Handling the colour transitions of the background view
    
    func randomColor(_ alpha: CGFloat) -> UIColor {
        let randomR:CGFloat = CGFloat(drand48())
        let randomG:CGFloat = CGFloat(drand48())
        let randomB:CGFloat = CGFloat(drand48())
        return UIColor(red: randomR, green: randomG, blue: randomB, alpha: alpha)
    }
    
    func animateBackground() {
        
        UIView.animate(withDuration: BubbleSettings.backgroundTransition, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.view.backgroundColor = self.randomColor(1.0)
        }) { (Bool) -> Void in
            self.animateBackground()
        }
    }
    
    
    // MARK: BLow Bubbles!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first! as UITouch
        let location = touch.location(in: self.view)
        
        for bubble in self.bubbles {
            if bubble.frame.contains(location) {
                if (bubble.bubbleCharacter != nil) {
                    return
                }
            }
        }
        createBubble(touches.first! as UITouch)
    }

    func createBubble(_ sender: UITouch) {
        
        if (self.bubbles.count >= BubbleSettings.quantity) { return }
        
        let color = self.randomColor(max(randomFloat(), 0.5))
        self.bubbleLights.colorLights(color)
        
        let position:CGPoint = sender.location(in: self.view)
        let randomSize = CGFloat(arc4random_uniform(150) + 50)
        
        let bubble:Bubble = Bubble(frame: CGRect(x: 0, y: 0, width: randomSize, height: randomSize), colour: color)
        bubble.center = position
        bubble.bubbleDelegate = self
        bubble.alpha = 1.0
        bubble.bubbleCharacter = String(Character(UnicodeScalar(characters.character(at: Int(arc4random_uniform(UInt32(characters.length)))))!)) as NSString?
        bubble.bubbleFont = UIFont(name: fonts[Int(arc4random_uniform(UInt32(fonts.count)))], size: 1.0)
        
        self.view.addSubview(bubble)
        self.bubbles.append(bubble)

        bubble.playSound(BubbleSounds.create)
        
        if let rotation = self.currentRotation {
            bubble.transform = CGAffineTransform(rotationAngle: rotation)
        }
        
        bubble.collision = UICollisionBehavior(items: [bubble])
        bubble.collision!.translatesReferenceBoundsIntoBoundary = true
        bubble.collision!.collisionDelegate = self
        self.animator!.addBehavior(bubble.collision!)
        
        gravity.addItem(bubble)
        
        bubble.dynamicBehaviour = UIDynamicItemBehavior(items: [bubble])
        bubble.dynamicBehaviour!.density = randomFloat()
        bubble.dynamicBehaviour!.elasticity = randomFloat()
        bubble.dynamicBehaviour!.friction = randomFloat()
        bubble.dynamicBehaviour!.resistance = randomFloat()
        bubble.dynamicBehaviour!.allowsRotation = true
        self.animator!.addBehavior(bubble.dynamicBehaviour!)
        
        perform(#selector(BubbleController.clearBubble(_:)), with: bubble, afterDelay: BubbleSettings.longevity)
    }
    
    @objc func clearBubble(_ bubble: Bubble) {
        bubble.playSound(BubbleSounds.pop)
        UIView.animate(withDuration: 0.75, animations: { () -> Void in
            bubble.alpha = 0.0
        }, completion: { (Bool) -> Void in
            bubble.removeFromSuperview()
            self.gravity.removeItem(bubble)
            if (bubble.attachment != nil) {self.animator?.removeBehavior(bubble.attachment!)}
            if (bubble.collision != nil) {self.animator?.removeBehavior(bubble.collision!)}
            if (bubble.dynamicBehaviour != nil) {self.animator?.removeBehavior(bubble.dynamicBehaviour!)}
            if let foundIndex = self.bubbles.index(of: bubble) {
                self.bubbles.remove(at: foundIndex)
            }
        }) 
    }
    
    @objc func clearBubbles() {
        for bubble in self.bubbles { clearBubble(bubble) }
        self.bubbles = []
    }
    
    @objc func clearLights() {
        bubbleLights.resetLights()
    }
    
    //    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
    //        if let bubble = item as? Bubble {
    //    
    //        }
    //    }
    
    func moveBubble(_ bubble: Bubble, pan: UIPanGestureRecognizer) {
    
        let location = pan.location(in: self.view);
        
        switch pan.state {
            
        case UIGestureRecognizerState.began:
            if let color = bubble.bubbleColour {
                self.bubbleLights.colorLights(color)
            }
            if let attachment = bubble.attachment {
                self.animator?.removeBehavior(attachment)
            }
            bubble.attachment = UIAttachmentBehavior(item: bubble, attachedToAnchor: bubble.center)
            bubble.attachment!.length = 1.0
            bubble.attachment!.damping = 1.0
            bubble.attachment!.frequency = 1.0
            self.animator!.addBehavior(bubble.attachment!)
            
        case UIGestureRecognizerState.changed:
            updateAttachment(location, behaviour: bubble.attachment!)

        default:
            return
        }
        
    }
    
    @IBAction func moveBubbles(_ pan: UIPanGestureRecognizer) {
    
        let location = pan.location(in: self.view);
 
        switch pan.state {
            
        case UIGestureRecognizerState.began:

            for behaviour in self.animator!.behaviors {
                if behaviour.isKind(of: UIAttachmentBehavior.self) {
                    self.animator?.removeBehavior(behaviour )
                }
            }
            for view in self.bubbles {
                view.attachment = UIAttachmentBehavior(item: view, attachedToAnchor: view.center)
                view.attachment!.length = randomFloat()
                view.attachment!.damping = randomFloat()
                view.attachment!.frequency = randomFloat()
                self.animator!.addBehavior(view.attachment!)
            }
        case UIGestureRecognizerState.changed:
            for behaviour in self.animator!.behaviors {
                if behaviour.isKind(of: UIAttachmentBehavior.self) {
                    updateAttachment(location, behaviour: (behaviour as! UIAttachmentBehavior))
                }
            }
        default:
            return
        }
    }
    
    func updateAttachment(_ location: CGPoint, behaviour: UIAttachmentBehavior) {
        
        let yDistanceFromTouch:CGFloat = location.y - view.center.y
        let xDistanceFromTouch:CGFloat = location.x - view.center.x
        
        var centerPoint = view.center
        centerPoint.y += yDistanceFromTouch
        centerPoint.x += xDistanceFromTouch
        
        behaviour.anchorPoint = centerPoint
    }
    

    // MARK: Handling the device
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == UIEventSubtype.motionShake {
            clearBubbles()
        }
    }
    
    
    // MARK: Helper Methods
    
    func randomFloat() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
}

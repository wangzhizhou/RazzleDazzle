//
//  PathPositionAnimation.swift
//  RazzleDazzle
//
//  Created by Laura Skelton on 6/30/15.
//  Copyright © 2015 IFTTT. All rights reserved.
//

import UIKit

/**
Animates the view's position along the given path.
*/
@MainActor
open class PathPositionAnimation : Animation<CGFloat>, Animatable {
    fileprivate let view : UIView
    open var path : CGPath? {
        didSet {
            createKeyframeAnimation()
        }
    }
    
    fileprivate let animationKey = "PathPosition"
    open var rotationMode : CAAnimationRotationMode = .rotateAuto {
        didSet {
            createKeyframeAnimation()
        }
    }
    
    public init(view: UIView, path: CGPath?) {
        self.view = view
        self.path = path
        super.init()
        
        self.createKeyframeAnimation()
        
        // CAAnimations are lost when application enters the background, so re-add them
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PathPositionAnimation.createKeyframeAnimation),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func animate(_ time: CGFloat) {
        if !hasKeyframes() {return}
        view.layer.timeOffset = CFTimeInterval(self[time])
    }
    
    open override func validateValue(_ value: CGFloat) -> Bool {
        return (value >= 0) && (value <= 1)
    }
    
    @objc fileprivate func createKeyframeAnimation() {
        // Set up a CAKeyframeAnimation to move the view along the path
        view.layer.add(pathAnimation(), forKey: animationKey)
        view.layer.speed = 0
        view.layer.timeOffset = 0
    }
    
    fileprivate func pathAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.path = path
        animation.duration = 1
        animation.isAdditive = true
        animation.repeatCount = Float.infinity
        animation.calculationMode = CAAnimationCalculationMode.paced
        animation.rotationMode = rotationMode
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false
        return animation
    }
}

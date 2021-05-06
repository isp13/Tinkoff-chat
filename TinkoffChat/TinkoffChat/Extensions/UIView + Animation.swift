//
//  UIView + Animation.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 26.04.2021.
//

import UIKit

extension UIView {
    
    func animateJiggle() {
        layer.removeAnimation(forKey: "shake")
        let xOffset: CGFloat = -5
        let xAnimation = CAKeyframeAnimation()
        xAnimation.keyPath = "position.x"
        xAnimation.values = [center.x, center.x + xOffset, center.x, center.x - xOffset, center.x]
        xAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        
        let yOffset: CGFloat = -5
        let yAnimation = CAKeyframeAnimation()
        yAnimation.keyPath = "position.y"
        yAnimation.values = [center.y, center.y + yOffset, center.y, center.y - yOffset, center.y]
        yAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        
        let angle = Double.pi / 10
        let rotateAnimation = CAKeyframeAnimation()
        rotateAnimation.keyPath = "transform.rotation"
        rotateAnimation.values = [0, angle, 0, -angle, 0]
        rotateAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        rotateAnimation.duration = 0.15
        rotateAnimation.repeatCount = 2
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [xAnimation, yAnimation, rotateAnimation]
        animationGroup.duration = 0.3
        animationGroup.repeatCount = .infinity
        animationGroup.fillMode = .forwards
        layer.add(animationGroup, forKey: "shake")
    }
    
    func animateStopJiggle() {
        guard let layer = layer.presentation() else { return }
        layer.removeAnimation(forKey: "shake")
        
        let positionAnimation = CAKeyframeAnimation()
        positionAnimation.keyPath = "position"
        positionAnimation.values = [layer.position, center]
        positionAnimation.keyTimes = [0, 1]
        
        let rotateAnimation = CAKeyframeAnimation()
        rotateAnimation.keyPath = "transform.rotation"
        rotateAnimation.values = [layer.value(forKeyPath: "transform.rotation.z") ?? 0, 0]
        rotateAnimation.keyTimes = [0, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, rotateAnimation]
        animationGroup.duration = 1
        animationGroup.fillMode = .both
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        layer.add(animationGroup, forKey: "shakeStop")
    }
    
}

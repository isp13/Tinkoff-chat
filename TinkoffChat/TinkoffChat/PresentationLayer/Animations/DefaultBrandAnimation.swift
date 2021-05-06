//
//  DefaultBrandAnimation.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 29.04.2021.
//

import UIKit

class DefaultBrandAnimationEmitter {
    lazy var tinkoffEmitterCell: CAEmitterCell = {
        var cell = CAEmitterCell()
        cell.contents = UIImage(named: "brand")?.cgImage
        cell.scale = 0.05
        cell.scaleRange = 0.05
        cell.emissionRange = .pi
        cell.lifetime = 0.4
        cell.birthRate = 5
        cell.velocity = 50
        cell.velocityRange = 15
        cell.xAcceleration = 20
        cell.yAcceleration = 25
        cell.spin = -0.5
        cell.spinRange = 1.0
        
        return cell
    }()
    
    func createLayer(position: CGPoint, size: CGSize) -> CAEmitterLayer {
        let flakeLayer = CAEmitterLayer()
        flakeLayer.emitterPosition = position
        flakeLayer.emitterSize = size
        flakeLayer.emitterShape = .point
        flakeLayer.beginTime = CACurrentMediaTime()
        flakeLayer.timeOffset = CFTimeInterval(arc4random_uniform(6) + 5)
        flakeLayer.emitterCells = [tinkoffEmitterCell]
        return flakeLayer
    }
}

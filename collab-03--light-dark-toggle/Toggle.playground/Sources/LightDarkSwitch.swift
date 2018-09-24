//
//  LightDarkSwitch.swift
//  Toggle
//
//  Created by John Martin on 16/09/2018.
//  Copyright © 2018 Martinsoft. All rights reserved.
//

import UIKit

public class LightDarkSwitch: UIControl {
    
    private let bar = CALayer()
    private let dot = DotLayer()
    
    private(set) var switchState = SwitchState.off
    
    override public var bounds: CGRect { didSet { updateFrames() } }
    
    private var insetAmount: CGFloat { return bounds.height * 0.1438 }
    
    enum SwitchState {
        case off, on
        
        var background: CGColor {
            switch self {
                case .off: return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
                case .on:  return #colorLiteral(red: 0.137254902, green: 0.1215686275, blue: 0.1254901961, alpha: 1).cgColor
            }
        }
        
        var bar: (border: CGColor, background: CGColor) {
            switch self {
                case .off: return (border: #colorLiteral(red: 0.8274509804, green: 0.768627451, blue: 0.8078431373, alpha: 1).cgColor, background: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor)
                case .on:  return (border: #colorLiteral(red: 0.9137254902, green: 0.0862745098, blue: 0.5490196078, alpha: 1).cgColor, background: #colorLiteral(red: 0.9137254902, green: 0.0862745098, blue: 0.5490196078, alpha: 1).cgColor)
            }
        }
        
        var dot: (fill: CGColor, highlight: CGColor, rotate: CGFloat) {
            switch self {
                case .off: return (fill: #colorLiteral(red: 0.9137254902, green: 0.0862745098, blue: 0.5490196078, alpha: 1).cgColor, highlight: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor, rotate: -CGFloat.pi)
                case .on:  return (fill: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor, highlight: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor, rotate: CGFloat.pi)
            }
        }
        
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        [bar, dot].forEach { layer.addSublayer($0) }
        updateFrames()
        
        dot.backgroundColor = SwitchState.off.dot.fill
        dot.highlight.fillColor = SwitchState.off.dot.highlight
        bar.borderWidth = 1.0
        bar.borderColor = SwitchState.off.bar.border
        bar.backgroundColor = SwitchState.off.bar.background
        
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
    }
    
    private func updateFrames() {
        bar.frame = bounds
        bar.cornerRadius = bar.bounds.height / 2.0
        
        let dotHeight = bounds.insetBy(dx: insetAmount, dy: insetAmount).height
        dot.bounds = CGRect(x: 0, y: 0, width: dotHeight, height: dotHeight)
        dot.cornerRadius = dotHeight / 2.0
        dot.position = position(for: switchState)
    }
    
    @objc private func toggleState() {
        let oldState = switchState
        switchState = switchState == .on ? .off : .on
        animate(from: oldState, to: switchState)
    }
    
    private func position(for SwitchState: SwitchState) -> CGPoint {
        switch SwitchState {
            case .on:  return CGPoint(x: bounds.width - insetAmount - (dot.bounds.width / 2.0), y: bounds.height / 2.0)
            case .off: return CGPoint(x: insetAmount + (dot.bounds.width / 2.0), y: bounds.height / 2.0)
        }
    }
    
    private func animate(from fromState: SwitchState, to toState: SwitchState) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        CATransaction.setAnimationDuration(0.5)
        animateDot(from: fromState, to: toState)
        animateBar(from: fromState, to: toState)
        animateSuperview(from: fromState, to: toState)
        CATransaction.commit()
    }
    
    private func animateBar(from: SwitchState, to: SwitchState) {
        bar.animate("borderColor", from: from.bar.border, to: to.bar.border)
        bar.animate("backgroundColor", from: from.bar.background, to: to.bar.background)
    }
    
    private func animateDot(from fromState: SwitchState, to toState: SwitchState) {
        let currentAngle = dot.value(forKeyPath: "transform.rotation.z") as? CGFloat ?? 0
        dot.animate("transform.scale", times: [0, 0.2, 0.8, 1], values: [1, 0.8, 0.8, 1])
        dot.animate("position", from: position(for: fromState), to: position(for: toState))
        dot.animate("backgroundColor", from: fromState.dot.fill, to: toState.dot.fill)
        dot.animate("transform.rotation.z", from: currentAngle, to: currentAngle + toState.dot.rotate)
        dot.highlight.animate("fillColor", from: fromState.dot.highlight, to: toState.dot.highlight)
    }
    
    private func animateSuperview(from fromState: SwitchState, to toState: SwitchState) {
        superview?.layer.animate("backgroundColor", from: fromState.background, to: toState.background)
    }
    
    private class DotLayer: CALayer {
        let highlight = CAShapeLayer()
        
        override var bounds: CGRect {
            didSet {
                highlight.frame = bounds
                let radius = bounds.width / 2.0
                let angle  = (Float.pi / 2.0) * 0.50
                let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: radius,
                                        startAngle: CGFloat.pi / 2.0,
                                        endAngle: -CGFloat.pi / 2.0,
                                        clockwise: true)

                path.addArc(withCenter: CGPoint(x: bounds.midX + radius * CGFloat(tan(angle)), y: bounds.midY),
                            radius: radius / CGFloat(cosf(angle)),
                            startAngle: CGFloat(-Float.pi / 2.0 - angle),
                            endAngle: CGFloat(Float.pi / 2.0 + angle),
                            clockwise: false)
                path.close()
                highlight.path = path.cgPath
            }
        }
        
        override init() {
            super.init()
            highlight.lineWidth = 0.5
            addSublayer(highlight)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("Not implemented")
        }
        
    }
    
}

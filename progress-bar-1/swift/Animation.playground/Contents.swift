//
//  COLLAB MONDAYS: Design and Code collaboration with @designbynadia and @sasha.codes:
//  [@designbynadia](https://instagram.com/designbynadia)
//  [@sasha.codes](https://instagram.com/sasha.codes)
//
//  Design: Copyright © @designbynadia.
//  Code:   Copyright © 2018 Martinsoft Limited.
//
//  All rights reserved.
//

import UIKit
import PlaygroundSupport

// MARK: - BarState

enum BarState {
    case incomplete
    case complete

    private var primaryColor:   UIColor { return UIColor(red: 0.78, green: 0.26, blue: 0.53, alpha: 1.00) }
    private var secondaryColor: UIColor { return UIColor(red: 0.39, green: 0.38, blue: 0.38, alpha: 1.00) }
    
    var color: UIColor { return self == .complete ? primaryColor : secondaryColor }
    var width: CGFloat { return self == .complete ? 2 : 1 }
}


// MARK: - ProgressBar

struct ProgressBar {
    
    private let barIncomplete: CAShapeLayer
    private let barComplete: CAShapeLayer
    private let slider: CAShapeLayer
    private let tick: CAShapeLayer
    
    private let start: CGPoint
    private let end: CGPoint

    private let sliderSize = CGSize(width: 15, height: 15)
    
    private let slideTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

    private var sliderRadiusProportionalToBar: CGFloat {
        let barWidth = end.x - start.x
        return sliderSize.width / CGFloat(2.0) / barWidth
    }
    
    init(view: UIView, startX: CGFloat, endX: CGFloat, y: CGFloat) {
        start = CGPoint(x: startX, y: y)
        end = CGPoint(x: endX, y: y)

        let barPath = UIBezierPath()
        barPath.move(to: start)
        barPath.addLine(to: end)
        barIncomplete = CAShapeLayer(with: barPath.cgPath, color: BarState.incomplete.color, width: BarState.incomplete.width)
        barComplete   = CAShapeLayer(with: barPath.cgPath, color: BarState.complete.color, width: BarState.complete.width)
        barComplete.strokeStart = 1.0
        
        slider = createDot(position: start, color: BarState.complete.color.cgColor, size: sliderSize)
        tick   = createTick(position: end, color: BarState.complete.color.cgColor)
        tick.opacity = 0

        [barIncomplete, barComplete, slider, tick].forEach(view.layer.addSublayer(_:))
    }
    
    func animate(startDelay: CFTimeInterval, duration: CFTimeInterval) {
        
        let slideDuration = duration
        let floatDuration = 0.15
        let slidePauseDuration = 0.1
        let totalDuration = duration + slidePauseDuration + floatDuration
        let tailShrinkBeginTime = slideDuration * 0.25

        let startTime = CACurrentMediaTime() + startDelay
        
        let incompleteBarStart = Double(sliderRadiusProportionalToBar) * 2.0
        let incompleteDuration = slideDuration * (1.0 - incompleteBarStart)
        let incompleteBarAnimations = CAAnimationGroup([
            CABasicAnimation(
                keyPath: "strokeStart",
                from: incompleteBarStart,
                to: 1,
                duration: incompleteDuration
            ),
            CABasicAnimation(
                keyPath: "strokeStart",
                from: 1,
                to: 1,
                beginTime: incompleteDuration,
                duration: totalDuration - incompleteDuration
            )
        ], duration: slideDuration)
        incompleteBarAnimations.beginTime = startTime
        incompleteBarAnimations.fillMode = kCAFillModeForwards
        incompleteBarAnimations.isRemovedOnCompletion = false
        incompleteBarAnimations.timingFunction = slideTimingFunction
        
        let barCompleteAnimations = CAAnimationGroup([
            CABasicAnimation(
                keyPath: "strokeStart",
                from: 0,
                to: 0,
                duration: tailShrinkBeginTime
            ),
            CABasicAnimation(
                keyPath: "strokeEnd",
                from: 0,
                to: 1,
                duration: slideDuration
            ),
            CABasicAnimation(
                keyPath: "strokeStart",
                from: 0,
                to: 1,
                beginTime: tailShrinkBeginTime,
                duration: slideDuration - tailShrinkBeginTime
            )
        ], duration: slideDuration)
        barCompleteAnimations.fillMode = kCAFillModeForwards
        barCompleteAnimations.beginTime = incompleteBarAnimations.beginTime
        barCompleteAnimations.isRemovedOnCompletion = false
        barCompleteAnimations.timingFunction = slideTimingFunction
        
        let sliderAnimation = CABasicAnimation(
            keyPath: "position",
            from: start,
            to: end,
            duration: slideDuration
        )
        sliderAnimation.beginTime = startTime
        sliderAnimation.fillMode = kCAFillModeForwards
        sliderAnimation.isRemovedOnCompletion = false
        sliderAnimation.timingFunction = slideTimingFunction
        
        let sliderFloatAndFade = CAAnimationGroup([
            CABasicAnimation(
                keyPath: "position.y",
                byValue: -20
            ),
            CABasicAnimation(
                keyPath: "opacity",
                byValue: -1
            )
        ], duration: floatDuration)
        sliderFloatAndFade.beginTime = startTime + slideDuration + slidePauseDuration
        sliderFloatAndFade.duration = floatDuration
        sliderFloatAndFade.fillMode = kCAFillModeForwards
        sliderFloatAndFade.isRemovedOnCompletion = false
        
        let tickAnimations = CAAnimationGroup([
            CABasicAnimation(
                keyPath: "position.y",
                byValue: -30
            ),
            CABasicAnimation(
                keyPath: "opacity",
                from: 0,
                to: 1
            )
        ], duration: sliderFloatAndFade.duration)
        tickAnimations.fillMode = kCAFillModeForwards
        tickAnimations.isRemovedOnCompletion = false
        tickAnimations.beginTime = sliderFloatAndFade.beginTime
        
        slider.add(sliderAnimation, forKey: "slider.position")
        slider.add(sliderFloatAndFade, forKey: "slider.float.fade")
        barIncomplete.add(incompleteBarAnimations, forKey: "bar.incomplete")
        barComplete.add(barCompleteAnimations, forKey: "bar.complete")
        tick.add(tickAnimations, forKey: "tick")
    }
    
}


// MARK: - Main

// Set up view for playground
let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.backgroundColor = .white
PlaygroundPage.current.liveView = view

let progressBar = ProgressBar(view: view, startX: 40, endX: view.bounds.width - 40, y: view.bounds.midY)
progressBar.animate(startDelay: 2.0, duration: 1.5)


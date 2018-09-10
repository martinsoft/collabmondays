import UIKit

public func createDot(position: CGPoint, color: CGColor, size: CGSize) -> CAShapeLayer {
    let dot = CAShapeLayer()
    dot.bounds = CGRect(origin: .zero, size: size)
    dot.position = position
    dot.path = UIBezierPath(ovalIn: dot.bounds).cgPath
    dot.fillColor = color
    return dot
}


public func createTick(position: CGPoint, color: CGColor) -> CAShapeLayer {
    let tick = CAShapeLayer()
    tick.strokeColor = color
    tick.bounds = CGRect(x: 0, y: 0, width: 20, height: 15)
    
    let tickPath = UIBezierPath()
    tickPath.move(to: CGPoint(x: 0.74, y: 8.94))
    tickPath.addLine(to: CGPoint(x: 6.72, y: 14.52))
    tickPath.move(to: CGPoint(x: 5.14, y: 14.58))
    tickPath.addLine(to: CGPoint(x: 19.41, y: 0.7))
    tickPath.miterLimit = 4
    
    tick.path = tickPath.cgPath
    tick.lineWidth = 2
    tick.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    tick.position = position
    tick.transform = CATransform3DMakeScale(0.75, 0.75, 1.0)
    
    return tick
}


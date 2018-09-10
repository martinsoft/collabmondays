import UIKit

// MARK: - CAShapeLayer

public extension CAShapeLayer {
    
    convenience init(with path: CGPath, color: UIColor, width: CGFloat) {
        self.init()
        self.path = path
        self.strokeColor = color.cgColor
        self.lineWidth = width
    }
    
}


// MARK: - CABasicAnimation

public extension CABasicAnimation {
    
    convenience init(keyPath: String, from: Any?, to: Any?) {
        self.init(keyPath: keyPath)
        fromValue = from
        toValue = to
    }
    
    convenience init(keyPath: String, from: Any?, to: Any?, beginTime: CFTimeInterval = 0) {
        self.init(keyPath: keyPath, from: from, to: to)
        self.beginTime = beginTime
    }
    
    convenience init(keyPath: String, from: Any?, to: Any?, beginTime: CFTimeInterval = 0, duration: CFTimeInterval) {
        self.init(keyPath: keyPath, from: from, to: to, beginTime: beginTime)
        self.duration = duration
    }
    
    convenience init(keyPath: String, byValue: Any) {
        self.init(keyPath: keyPath)
        self.byValue = byValue
    }
    
}


// MARK: - CAAnimationGroup

public extension CAAnimationGroup {
    
    convenience init(_ animations: [CAAnimation]) {
        self.init()
        self.animations = animations
    }
    
    convenience init(_ animations: [CAAnimation], duration: CFTimeInterval) {
        self.init(animations)
        self.duration = duration
    }
    
}

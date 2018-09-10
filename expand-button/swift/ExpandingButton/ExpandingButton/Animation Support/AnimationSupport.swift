import UIKit

extension CALayer {
    
    func commitAnimations(completionBlock: (() -> Void)? = nil, body: (_ beginTime: CFTimeInterval) -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock(completionBlock)
        body(convertTime(CACurrentMediaTime(), to: nil))
        CATransaction.commit()
    }
    
    func animateAndSet(animation: CABasicAnimation) {
        guard let keyPath = animation.keyPath else { return }
        animation.fromValue = animation.fromValue ?? presentation()?.value(forKey: keyPath) ?? value(forKeyPath: keyPath)
        setValue(animation.toValue, forKeyPath: keyPath)
        add(animation, forKey: animation.keyPath)
    }
    
    func animateAndSet(beginTime: CFTimeInterval, duration: CFTimeInterval, timing: CAMediaTimingFunction = AnimationTiming.linear, animations: [CABasicAnimation]) {
        animations.forEach { anim in
            anim.beginTime = beginTime
            anim.duration = duration
            animateAndSet(animation: anim)
        }
    }
    
}

struct AnimationTiming {
    static let linear = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    static let easeIn = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    static let easeOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    static let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
}

extension CABasicAnimation {
    convenience init(
        keyPath: String,
        to: Any,
        beginTime: CFTimeInterval = 0,
        duration: CFTimeInterval = 0.25,
        fillMode: String = kCAFillModeRemoved,
        timing: CAMediaTimingFunction = AnimationTiming.linear
    ) {
        self.init(keyPath: keyPath)
        self.toValue = to
        self.beginTime = beginTime
        self.duration = duration
        self.fillMode = fillMode
        self.timingFunction = timing
    }
}


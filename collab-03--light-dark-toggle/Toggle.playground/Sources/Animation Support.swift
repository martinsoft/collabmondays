import UIKit

extension CABasicAnimation {
    convenience init(keyPath: String, from fromValue: Any?, to toValue: Any?) {
        self.init(keyPath: keyPath)
        self.fromValue = fromValue
        self.toValue = toValue
    }
}

extension CALayer {
    func animate(_ keyPath: String, from fromValue: Any?, to toValue: Any?) {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue ?? presentation()?.value(forKey: keyPath) ?? value(forKeyPath: keyPath)
        animation.toValue = toValue
        setValue(animation.toValue, forKeyPath: keyPath)
        add(animation, forKey: animation.keyPath)
    }

    func animate(_ keyPath: String, times: [NSNumber]?, values: [NSNumber]?) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times
        animation.values = values
        add(animation, forKey: nil)
    }
}

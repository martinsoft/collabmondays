import UIKit

final class ExpandingButton: UIButton {
    
    let inactiveColor = #colorLiteral(red: 0.7764705882, green: 0.7176470588, blue: 0.7647058824, alpha: 1)
    let inactiveFill = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    let activeColor = #colorLiteral(red: 0.7843137255, green: 0.262745098, blue: 0.5333333333, alpha: 1)

    let expandSpeed = 0.1
    let collapseSpeed = 0.1
    
    var expandedAction: (() -> Void)?

    private let bar = CAShapeLayer()

    override func willMove(toSuperview newSuperview: UIView?) {
        layer.addSublayer(bar)
        bar.frame = bounds
        bar.path = roundedRectPath(in: bounds)
        bar.lineWidth = 1.0
        bar.fillColor = inactiveFill.cgColor
        bar.strokeColor = inactiveColor.cgColor
        removeTarget(self, action: nil, for: .allEvents)
        addTarget(self, action: #selector(shrink), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(growBack), for: [.touchUpOutside, .touchDragExit])
        addTarget(self, action: #selector(expand), for: .touchUpInside)
    }
    
    var shrunkFrame: CGRect {
        return CGRect(x: (bounds.width - bounds.height) / 2.0, y: 0, width: bounds.height, height: bounds.height)
    }
    
    func roundedRectPath(in rect: CGRect) -> CGPath {
        return UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2.0).cgPath
    }
    
    @objc private func shrink() {
        bar.commitAnimations { beginTime in
            animateShrink(beginTime: beginTime, duration: 0.3)
        }
    }
    
    @objc private func growBack() {
        bar.removeAllAnimations()
        bar.commitAnimations { beginTime in
            animateExpand(beginTime: beginTime, duration: 0.3)
        }
    }
    
    @objc private func expand() {
        bar.commitAnimations(completionBlock: expandedAction) { beginTime in
            animateShrink(beginTime: beginTime, duration: 0.1)
            animateScaleUp(beginTime: beginTime + 0.3, duration: expandSpeed)
            animateOpacity(to: 0.5, beginTime: beginTime + 0.3, duration: expandSpeed)
        }
    }
    
    private func animateOpacity(to value: CGFloat, beginTime: CFTimeInterval, duration: CFTimeInterval) {
        bar.animateAndSet(animation:
            CABasicAnimation(
                keyPath: "opacity",
                to: value,
                beginTime: beginTime,
                duration: duration,
                fillMode: kCAFillModeBackwards
            )
        )
    }
    
    public func collapse() {
        bar.removeAllAnimations()
        bar.commitAnimations { beginTime in
            animateOpacity(to: 1.0, beginTime: beginTime, duration: collapseSpeed)
            animateScaleBack(beginTime: beginTime, duration: collapseSpeed)
            animateExpand(beginTime: beginTime + collapseSpeed + 0.2, duration: collapseSpeed)
        }
    }

    private func animateShrink(beginTime: CFTimeInterval, duration: CFTimeInterval) {
        bar.animateAndSet(beginTime: beginTime, duration: duration, timing: AnimationTiming.easeIn, animations: [
            CABasicAnimation(
                keyPath: "path",
                to: roundedRectPath(in: shrunkFrame)
            ),
            CABasicAnimation(
                keyPath: "strokeColor",
                to: activeColor.cgColor,
                fillMode: kCAFillModeBackwards
            ),
            CABasicAnimation(
                keyPath: "fillColor",
                to: activeColor.cgColor,
                fillMode: kCAFillModeBackwards
            )
        ])
    }
    
    private func animateExpand(beginTime: CFTimeInterval, duration: CFTimeInterval) {
        bar.animateAndSet(beginTime: beginTime, duration: duration, timing: AnimationTiming.easeOut, animations: [
            CABasicAnimation(
                keyPath: "path",
                to: roundedRectPath(in: bounds),
                fillMode: kCAFillModeBackwards
            ),
            CABasicAnimation(
                keyPath: "fillColor",
                to: inactiveFill.cgColor,
                fillMode: kCAFillModeBackwards
            ),
            CABasicAnimation(
                keyPath: "strokeColor",
                to: inactiveColor.cgColor,
                fillMode: kCAFillModeBackwards
            )
        ])
    }
    
    private func animateScaleUp(beginTime: CFTimeInterval, duration: CFTimeInterval) {
        guard let expandedBounds = superview?.bounds.applying(CGAffineTransform(scaleX: sqrt(2), y: sqrt(2))) else { return }
        let scaleFactor = expandedBounds.width / shrunkFrame.width
        bar.animateAndSet(animation: CABasicAnimation(
            keyPath: "transform",
            to: CATransform3DMakeScale(scaleFactor, scaleFactor, 0.2),
            beginTime: beginTime,
            duration: duration,
            fillMode: kCAFillModeBackwards,
            timing: AnimationTiming.easeInOut
        ))
    }
    
    private func animateScaleBack(beginTime: CFTimeInterval, duration: CFTimeInterval) {
        bar.animateAndSet(animation: CABasicAnimation(
            keyPath: "transform",
            to: CATransform3DIdentity,
            beginTime: beginTime,
            duration: duration,
            timing: AnimationTiming.easeInOut
        ))
    }
    
}

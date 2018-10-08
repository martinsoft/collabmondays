import UIKit
import PlaygroundSupport


// MARK: - Dot Button

class DotButton: UIButton {
    
    let color: UIColor
    private(set) var isOn = false

    init(position: CGPoint, size: CGSize, color: UIColor) {
        self.color = color
        let scale = CGAffineTransform(translationX: -size.width / 2.0, y: -size.height / 2.0)
        super.init(frame: CGRect(origin: position.applying(scale), size: size))
        layer.backgroundColor = color.cgColor
        layer.borderColor = color.cgColor
        layer.cornerRadius = max(size.width, size.height) / 2.0
        layer.borderWidth = 1.0
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Not used") }

    var position: CGPoint { return CGPoint(x: frame.midX, y: frame.midY) }
    
    func toggleSelected() {
        isOn = !isOn
        CATransaction.begin(withDuration: 0.2, enableActions: false)
        if isOn {
            layer.animate("transform.scale", from: 1.0, to: 1.2)
            layer.animate("backgroundColor", from: color.cgColor, to: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor)
        } else {
            layer.animate("transform.scale", from: 1.2, to: 1.0)
            layer.animate("backgroundColor", from: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, to: color.cgColor)
        }
        CATransaction.commit()
    }
    
    enum FadeDirection { case fadeIn, fadeOut }
    
    func fade(_ fadeDirection: FadeDirection, duration: Double) {
        UIView.animate(withDuration: duration) {
            self.alpha = fadeDirection == .fadeIn ? 1 : 0
        }
    }
    
    func pulse(scale: CGFloat, duration: Double, completion: @escaping () -> Void) {
        let originalTransform = transform
        let half = duration / 2
        UIView.animate(withDuration: half, delay: 0, options: [.curveLinear], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: half, delay: 0, options: [.curveLinear], animations: {
                self.transform = originalTransform
            }) { _ in
                completion()
            }
        }
    }
    
}


// MARK: - Counter

class Counter {
    
    let layer = CALayer()
    let textLayer = CATextLayer()
    var displayLink: CADisplayLink!
    let defaultFontSize: CGFloat = 14
    
    init(position: CGPoint, size: CGSize, color: UIColor) {
        layer.bounds = CGRect(origin: .zero, size: size)
        layer.backgroundColor = color.cgColor
        layer.borderColor = color.cgColor
        layer.cornerRadius = max(size.width, size.height) / 2
        layer.borderWidth = 1
        layer.position = position
        
        textLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        textLayer.font = UIFont.systemFont(ofSize: defaultFontSize)
        textLayer.fontSize = defaultFontSize
        textLayer.foregroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        textLayer.alignmentMode = .center
        
        updateTextLayer()
        layer.addSublayer(textLayer)
        
        // Used to ensure text is positioned correctly during scale animation
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
    }
    
    func updateTextLayer() {
        let layer = self.layer.presentation() ?? self.layer
        let fontSize = (textLayer.presentation() ?? textLayer).fontSize
        let size = CGSize(width: layer.bounds.size.width, height: fontSize * 1.2)
        textLayer.position = CGPoint(x: 0, y: layer.bounds.midY)
        textLayer.bounds = CGRect(origin: .zero, size: size)
    }
    
    func setValue(_ value: Int) {
        CATransaction.begin(withDuration: 0, enableActions: false)
        textLayer.string = "\(value)"
        updateTextLayer()
        CATransaction.commit()
    }
    
    func animateScale(to scale: CGFloat, duration: Double, completion: @escaping () -> Void) {
        let newSize = layer.bounds.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        CATransaction.begin(withDuration: duration, timingFunction: .linear)
        CATransaction.setCompletionBlock(completion)
        layer.bounds = CGRect(origin: .zero, size: newSize)
        layer.cornerRadius = max(newSize.width, newSize.height) / 2
        textLayer.fontSize = textLayer.fontSize * scale
        CATransaction.commit()
    }
    
    func startDisplayLink() {
        displayLink.add(to: .current, forMode: .common)
    }
    
    func stopDisplayLink() {
        displayLink.invalidate()
    }
    
    @objc private func handleDisplayLink() {
        CATransaction.begin(withDuration: 0, enableActions: false)
        updateTextLayer()
        CATransaction.commit()
    }
    
}


// MARK: - Tick layer

class Tick: CAShapeLayer {
    
    convenience init(color: CGColor) {
        self.init()
        strokeColor = color
        bounds = CGRect(x: 0, y: 0, width: 20, height: 15)
        
        let tickPath = UIBezierPath()
        tickPath.move(to: CGPoint(x: 0.74, y: 8.94))
        tickPath.addLine(to: CGPoint(x: 6.72, y: 14.52))
        tickPath.move(to: CGPoint(x: 5.14, y: 14.58))
        tickPath.addLine(to: CGPoint(x: 19.41, y: 0.7))
        tickPath.miterLimit = 4
        
        path = tickPath.cgPath
        lineWidth = 2
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
}


// MARK: - View controller

class ViewController : UIViewController {

    let dotColors = [
        [ #colorLiteral(red: 0.9764705882, green: 0.9294117647, blue: 0.1960784314, alpha: 1), #colorLiteral(red: 0.8431372549, green: 0.8745098039, blue: 0.1333333333, alpha: 1), #colorLiteral(red: 0.5529411765, green: 0.7764705882, blue: 0.2470588235, alpha: 1), #colorLiteral(red: 0.2235294118, green: 0.7058823529, blue: 0.2862745098, alpha: 1), #colorLiteral(red: 0.003921568627, green: 0.5803921569, blue: 0.262745098, alpha: 1), #colorLiteral(red: 0.003921568627, green: 0.4078431373, blue: 0.2196078431, alpha: 1) ],
        [ #colorLiteral(red: 0.2039215686, green: 0.7098039216, blue: 0.4588235294, alpha: 1), #colorLiteral(red: 0.09803921569, green: 0.6509803922, blue: 0.6156862745, alpha: 1), #colorLiteral(red: 0.1921568627, green: 0.6705882353, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.1333333333, green: 0.462745098, blue: 0.7254901961, alpha: 1), #colorLiteral(red: 0.1725490196, green: 0.2352941176, blue: 0.5568627451, alpha: 1), #colorLiteral(red: 0.1490196078, green: 0.1411764706, blue: 0.3764705882, alpha: 1) ],
        [ #colorLiteral(red: 0.3960784314, green: 0.1921568627, blue: 0.5607843137, alpha: 1), #colorLiteral(red: 0.568627451, green: 0.1764705882, blue: 0.5529411765, alpha: 1), #colorLiteral(red: 0.6117647059, green: 0.137254902, blue: 0.3882352941, alpha: 1), #colorLiteral(red: 0.8470588235, green: 0.1333333333, blue: 0.368627451, alpha: 1), #colorLiteral(red: 0.9215686275, green: 0.1882352941, blue: 0.4862745098, alpha: 1), #colorLiteral(red: 0.7568627451, green: 0.7098039216, blue: 0.6117647059, alpha: 1) ],
        [ #colorLiteral(red: 0.6039215686, green: 0.5215686275, blue: 0.4784313725, alpha: 1), #colorLiteral(red: 0.4470588235, green: 0.4, blue: 0.3490196078, alpha: 1), #colorLiteral(red: 0.3490196078, green: 0.2901960784, blue: 0.2588235294, alpha: 1), #colorLiteral(red: 0.7647058824, green: 0.6, blue: 0.4352941176, alpha: 1), #colorLiteral(red: 0.6588235294, green: 0.4862745098, blue: 0.3254901961, alpha: 1), #colorLiteral(red: 0.5411764706, green: 0.368627451, blue: 0.2470588235, alpha: 1) ],
        [ #colorLiteral(red: 0.4549019608, green: 0.2980392157, blue: 0.1725490196, alpha: 1), #colorLiteral(red: 0.3725490196, green: 0.2235294118, blue: 0.09019607843, alpha: 1), #colorLiteral(red: 0.231372549, green: 0.1411764706, blue: 0.0862745098, alpha: 1), #colorLiteral(red: 0.9176470588, green: 0.1294117647, blue: 0.1764705882, alpha: 1), #colorLiteral(red: 0.737254902, green: 0.1294117647, blue: 0.1921568627, alpha: 1), #colorLiteral(red: 0.9254901961, green: 0.262745098, blue: 0.2392156863, alpha: 1) ],
        [ #colorLiteral(red: 0.9333333333, green: 0.3568627451, blue: 0.2039215686, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.5764705882, blue: 0.1921568627, alpha: 1), #colorLiteral(red: 0.9764705882, green: 0.6862745098, blue: 0.2980392157, alpha: 1), #colorLiteral(red: 0.9058823529, green: 0.6901960784, blue: 0.4588235294, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0.7058823529, blue: 0.5647058824, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0.7529411765, blue: 0.6745098039, alpha: 1) ],
    ]
    let buttonColor = #colorLiteral(red: 0.9137254902, green: 0.0862745098, blue: 0.5490196078, alpha: 1)

    let wrapperSize = CGSize(width: 600, height: 600)
    let spacing = CGSize(width: 78, height: 69)
    let dotSize = CGSize(width: 15, height: 15)
    let buttonSize = CGSize(width: 25, height: 25)
    let wrapper = UIView()
    
    var button: DotButton!    // The button is shown initially...
    var counter: Counter!     // ... then swapped for counter layer when tapped
    var tick: Tick!
    var dots = [DotButton]()
    var fallenDots = Set<DotButton>()

    var selectedDots: [DotButton] { return dots.filter { $0.isOn } }
    var unselectedDots: [DotButton] { return dots.filter { !$0.isOn } }

    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var bounce: UIDynamicItemBehavior!
    var collision: UICollisionBehavior!
    let floorBoundaryName = "floor"

    // Used to add motion trail behind the counter
    let replicator = CAReplicatorLayer()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.view = view
        
        setupWrapper()
        setupReplicator()
        setupTick()

        reset()
    }
    
    private func setupWrapper() {
        wrapper.layer.borderWidth = 1
        wrapper.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.clipsToBounds = true
        view.addSubview(wrapper)
        NSLayoutConstraint.activate([
            wrapper.widthAnchor.constraint(equalToConstant: wrapperSize.width),
            wrapper.heightAnchor.constraint(equalToConstant: wrapperSize.height),
            wrapper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wrapper.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupReplicator() {
        replicator.instanceCount = 3
        replicator.instanceAlphaOffset = -0.3
        replicator.instanceDelay = 0.05
        replicator.instanceTransform = CATransform3DMakeTranslation(0, 0, -10)
        replicator.anchorPoint = .zero
        replicator.position = .zero
        replicator.bounds = CGRect(origin: .zero, size: wrapperSize)
        wrapper.layer.insertSublayer(replicator, at: 999)
    }

    private func setupTick() {
        tick = Tick(color: buttonColor.cgColor)
        wrapper.layer.addSublayer(tick)
        tick.position = CGPoint(x: wrapperSize.width / 2, y: wrapperSize.height / 2)
    }
    
    private func addGravity() {
        gravity = UIGravityBehavior()
        gravity.magnitude = 0.5
        animator.addBehavior(gravity)
    }
    
    private func addBounce() {
        bounce = UIDynamicItemBehavior()
        bounce.elasticity = 0.8
        bounce.friction = 0.1
        animator.addBehavior(bounce)
    }
    
    private func addFloor() {
        collision = UICollisionBehavior()
        collision.collisionDelegate = self
        collision.collisionMode = .boundaries
        collision.addBoundary(withIdentifier: floorBoundaryName as NSCopying,
                              from: CGPoint(x: 0, y: button.frame.maxY),
                              to: CGPoint(x: wrapperSize.width, y: button.frame.maxY))
        animator.addBehavior(collision)
    }
    
    private func setUpDots() {
        let colCount = dotColors[0].count
        let rowCount = dotColors.count

        let gridWidth  = CGFloat(colCount - 1) * spacing.width
        let gridHeight = CGFloat(rowCount - 1) * spacing.height
        
        let minX = (wrapperSize.width - gridWidth) / 2
        let minY = (wrapperSize.height - gridHeight) / 2
        
        // Set up the grid
        for col in (0..<colCount) {
            for row in (0..<rowCount) {
                let pos = CGPoint(x: minX + CGFloat(col) * spacing.width,
                                  y: minY + CGFloat(row) * spacing.height)
                let dot = DotButton(
                              position: pos,
                              size: dotSize,
                              color: dotColors[row][col]
                          )
                dot.addTarget(self, action: #selector(dotPressed(dot:)), for: .touchUpInside)
                wrapper.addSubview(dot)
                dots.append(dot)
            }
        }
        
        // Add the button
        button = DotButton(
                    position: CGPoint(x: minX + gridWidth, y: minY + gridHeight + spacing.height),
                    size: buttonSize,
                    color: buttonColor
                 )
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.alpha = 0
        wrapper.addSubview(button)
        
        counter = Counter(
                    position: button.position,
                    size: button.bounds.size,
                    color: buttonColor
                  )
        counter.layer.isHidden = true
        replicator.addSublayer(counter.layer)
    }
    
    
    @objc func dotPressed(dot: DotButton) {
        dot.toggleSelected()
        button.fade(selectedDots.count == 0 ? .fadeOut : .fadeIn , duration: 0.1)
        counter.layer.isHidden = button.alpha == 0
    }
    
    @objc func buttonPressed() {
        button.pulse(scale: 1.5, duration: 0.2) {
            self.slideOffUnselectedDots {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.countUpSelectedDots()
                }
            }
        }
    }
    
    private func slideOffUnselectedDots(completion: @escaping () -> Void) {
        let translation = CGAffineTransform(translationX: wrapperSize.width, y: 0)
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.unselectedDots.forEach { dot in
                    dot.center = dot.center.applying(translation)
                    dot.alpha = 0
                }
            }, completion: { _ in
                completion()
            }
        )
    }
    
    private func countUpSelectedDots() {
        button.isHidden = true

        // Whilst animating the counter, force it to update using display link
        // Fixes a glitch with CATextLayer when animating font size and bounds together.
        counter.startDisplayLink()

        counterSlideToCenter()

        // Dots are counted when they collide with the floor
        selectedDots.forEach { dot in
            gravity.addItem(dot)
            bounce.addItem(dot)
            collision.addItem(dot)
        }
    }
    
    private func counterSlideToCenter() {
        CATransaction.begin(withDuration: 0.5)
        counter.layer.position.x = wrapperSize.width / 2.0
        CATransaction.commit()
    }
    
    private func countFallenDot(_ dot: DotButton) {
        fallenDots.insert(dot)
        counter.setValue(fallenDots.count)
        dot.fade(.fadeOut, duration: 0.2)
        
        guard fallenDots.count == selectedDots.count else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.allDotsCounted()
        }
    }
    
    private func allDotsCounted() {
        animator?.removeAllBehaviors()
        counter.animateScale(to: 1.6, duration: 0.05) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.counterRiseToTick()
            }
        }
    }
    
    private func counterRiseToTick() {
        CATransaction.begin(withDuration: 0.5, timingFunction: .easeOut)
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                self.counter.stopDisplayLink()
                self.tick.opacity = 1
                self.counter.layer.isHidden = true
            }
        }
        counter.layer.position.y = wrapperSize.height / 2.0
        CATransaction.commit()
    }
    
    @objc private func reset() {
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()
        if button != nil {
            button.removeFromSuperview()
            button = nil
        }
        if counter != nil {
            counter.layer.removeFromSuperlayer()
            counter = nil
        }
        setUpDots()
        
        fallenDots.removeAll()
        
        tick.opacity = 0
        
        animator = UIDynamicAnimator(referenceView: wrapper)
        addGravity()
        addBounce()
        addFloor()
    }
    
}

extension ViewController: UICollisionBehaviorDelegate {
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem,
                           withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        guard
            (identifier as? String) == floorBoundaryName,
            let dot = item as? DotButton
        else {
            return
        }
        countFallenDot(dot)
    }
    
}



let vc = ViewController()
vc.preferredContentSize = CGSize(width: vc.wrapperSize.width, height: vc.wrapperSize.height + 100)
PlaygroundPage.current.liveView = vc


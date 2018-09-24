import UIKit
import PlaygroundSupport

let view = UIView(frame: CGRect(x: 0, y: 0, width: 760, height: 760))
view.backgroundColor = .white

let toggle = LightDarkSwitch(frame: CGRect(x: 265, y: 342, width: 230, height: 75))
view.addSubview(toggle)

PlaygroundPage.current.liveView = view

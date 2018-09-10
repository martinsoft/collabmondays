import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var button: ExpandingButton!
    @IBOutlet weak var expandedView: UIView!
    
    override func viewDidLoad() {
        wrapperView.layer.borderColor = button.inactiveColor.cgColor
        wrapperView.layer.borderWidth = 1.0
        expandedView.backgroundColor = button.activeColor
        button.expandedAction = { [weak self] in
            self?.expandedView.isHidden = false
        }
    }
    
    @IBAction func closeExpandedView(_ sender: Any) {
        expandedView.isHidden = true
        button.collapse()
    }

    @IBAction func darkModeToggle(_ sender: UISwitch) {
        wrapperView.backgroundColor = sender.isOn ? #colorLiteral(red: 0.1333333333, green: 0.1215686275, blue: 0.1254901961, alpha: 1): #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}


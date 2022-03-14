//
//  LayerPopupViewController.swift
//  DrawingApp
//
//  Created by Bumgeun Song on 2022/03/14.
//

import UIKit

class LayerPopupViewController: UIViewController {
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
}

extension LayerPopupViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PopupController(presentedViewController: presented, presenting: presenting)
    }
    
}

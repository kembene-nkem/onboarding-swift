//
//  File.swift
//  
//
//  Created by Kembene Nkem on 7/27/22.
//

import Foundation
import UIKit

class BaseOnboardingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
}

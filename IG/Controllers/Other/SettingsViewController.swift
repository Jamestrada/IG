//
//  SettingsViewController.swift
//  IG
//
//  Created by James Estrada on 5/21/21.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
}

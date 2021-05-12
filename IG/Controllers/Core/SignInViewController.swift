//
//  SignInViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit

class SignInViewController: UIViewController {
    
    private let headerView = SignInHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        headerView.backgroundColor = .red
        view.addSubview(headerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: (view.height - view.safeAreaInsets.top) / 3)
    }
}

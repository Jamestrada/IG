//
//  SignInViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit

class SignInViewController: UIViewController {
    
    // Subviews
    private let headerView = SignInHeaderView()
    
    private let emailField: UITextField = {
        let field = UITextField()
        let outerView = UIView(frame: CGRect(x: 10, y: 0, width: 35, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "envelope")
        imageView.tintColor = .secondaryLabel
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        outerView.addSubview(imageView)
        
        field.placeholder = "Email Address"
//        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftView = outerView
        field.leftViewMode = .always
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .secondarySystemBackground
        headerView.backgroundColor = .red
        view.addSubview(headerView)
        view.addSubview(emailField)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: (view.height - view.safeAreaInsets.top) / 3)
        emailField.frame = CGRect(x: 25, y: headerView.bottom + 20, width: view.width - 50, height: 50)
    }
}

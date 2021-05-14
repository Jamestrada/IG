//
//  SignInViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // Subviews
    private let headerView = SignInHeaderView()
    
    private let emailField: IGTextField = {
        let field = IGTextField()
        let outerView = UIView(frame: CGRect(x: 10, y: 0, width: 35, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "envelope")
        imageView.tintColor = .secondaryLabel
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        outerView.addSubview(imageView)
        
        field.placeholder = "Email Address"
        field.leftView = outerView
        field.keyboardType = .emailAddress

        return field
    }()
    
    private let passwordField: IGTextField = {
        let field = IGTextField()
        let outerView = UIView(frame: CGRect(x: 10, y: 0, width: 35, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "lock")
        imageView.tintColor = .secondaryLabel
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        outerView.addSubview(imageView)
        
        field.placeholder = "Password"
        field.leftView = outerView
        field.keyboardType = .default
        field.isSecureTextEntry = true

        return field
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .secondarySystemBackground
        headerView.backgroundColor = .red
        addSubviews()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        addButtonActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: (view.height - view.safeAreaInsets.top) / 3)
        emailField.frame = CGRect(x: 25, y: headerView.bottom + 20, width: view.width - 50, height: 50)
        passwordField.frame = CGRect(x: 25, y: emailField.bottom + 10, width: view.width - 50, height: 50)
        signInButton.frame = CGRect(x: 35, y: passwordField.bottom + 20, width: view.width - 70, height: 50)
        createAccountButton.frame = CGRect(x: 35, y: signInButton.bottom + 20, width: view.width - 70, height: 50)
    }
    
    private func addSubviews() {
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
    }
    
    private func addButtonActions() {
        
    }
    
    // MARK: - Actions
    
    // MARK: Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

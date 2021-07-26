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
        let outerView = UIView(frame: CGRect(x: 10, y: 0, width: 40, height: 20))
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
        let outerView = UIView(frame: CGRect(x: 10, y: 0, width: 40, height: 20))
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
        view.backgroundColor = .systemBackground
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
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func didTapSignIn() {
        // dismiss keyboard when tapping the sign in button regardless of field the user is on
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty, // avoid spaces to count as valid inputs
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else { // the text property is optional on a field
            return
        }
        
        // Sign in with AuthManager
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    HapticManager.shared.vibrate(for: .success)
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen // prevent interface be swiped away
                    self?.present(vc, animated: true, completion: nil)
                    
                case .failure(let error):
                    HapticManager.shared.vibrate(for: .error)
                    print(error)
                }
            }
        }
    }
    
    @objc func didTapCreateAccount() {
        let vc = SignUpViewController()
        vc.completion = { [weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder() // pressing enter/next on the email field, the cursor will move to the password field
        } else {
            textField.resignFirstResponder() // pressing enter/next on the password field, the keyboard will be dismissed
            didTapSignIn()
        }
        return true
    }
}

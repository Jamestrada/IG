//
//  SignInViewController.swift
//  IG
//
//  Created by James Estrada on 5/9/21.
//

import UIKit
import JGProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var lowestElement: UIView!
    
    public lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentInsetAdjustmentBehavior = .never
        sv.contentSize = view.frame.size
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    
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
        button.backgroundColor = .systemGray
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
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        headerView.backgroundColor = .red
        addSubviews()
    
        view.addSubview(scrollView)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        addActions()
        signInButton.isEnabled = false
        
//        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        setupKeyboardNotifications()
    }
    
    lazy private var distanceToBottom = self.distanceFromLowestElementToBottom()
        
    private func distanceFromLowestElementToBottom() -> CGFloat {
        if lowestElement != nil {
            guard let frame = lowestElement.superview?.convert(lowestElement.frame, to: view) else { return 0 }
            let distance = view.frame.height - frame.origin.y - frame.height
            return distance
        }
        
        return view.frame.height - view.frame.maxY
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc func hideKeyboard() {
//        self.view.endEditing(true)
//    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardSize = value.cgRectValue
        
        if distanceToBottom > 0 {
            scrollView.contentInset.bottom -= distanceToBottom
        }
        
        scrollView.contentInset.bottom = keyboardSize.height
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardSize.height
    }
    
    @objc func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: (view.height - view.safeAreaInsets.top) / 3)
        emailField.frame = CGRect(x: 25, y: headerView.bottom + 20, width: view.width - 50, height: 50)
        passwordField.frame = CGRect(x: 25, y: emailField.bottom + 10, width: view.width - 50, height: 50)
        signInButton.frame = CGRect(x: 35, y: passwordField.bottom + 20, width: view.width - 70, height: 50)
        createAccountButton.frame = CGRect(x: 35, y: signInButton.bottom + 20, width: view.width - 70, height: 50)
    }
    
    private func addSubviews() {
        scrollView.addSubview(headerView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(signInButton)
        scrollView.addSubview(createAccountButton)
    }
    
    private func addActions() {
        emailField.addTarget(self, action: #selector(textFieldChangedValue(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldChangedValue(_:)), for: .editingChanged)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func textFieldChangedValue(_ textField: UITextField) {
        guard let emailCount = emailField.text?.count,
              let passwordCount = passwordField.text?.count else {
            return
        }
        if emailCount >= 3 && passwordCount >= 6 {
            signInButton.isEnabled = true
            signInButton.backgroundColor = .systemBlue
        }
        else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = .systemGray
        }
    }
    
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
        
        spinner.show(in: view)
        
        // Sign in with AuthManager
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.spinner.dismiss()
                switch result {
                case .success:
                    HapticManager.shared.vibrate(for: .success)
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen // prevent interface be swiped away
                    self?.present(vc, animated: true, completion: nil)
                    
                case .failure(let error):
                    HapticManager.shared.vibrate(for: .error)
                    self?.presentValidationError()
                    print(error)
                }
            }
        }
    }
    
    private func presentValidationError() {
        let alert = UIAlertController(title: "Woops", message: "Wrong email or password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
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

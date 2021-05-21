//
//  SignUpViewController.swift
//  IG
//
//  Created by James Estrada on 5/14/21.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Subviews
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabel
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill // fill up the circle
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameField: IGTextField = {
        let field = IGTextField()
        let outerView = UIView(frame: CGRect(x: 10, y: 0, width: 40, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: "person")
        imageView.tintColor = .secondaryLabel
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        outerView.addSubview(imageView)
        
        field.placeholder = "Username"
        field.leftView = outerView

        return field
    }()
    
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
        
        field.placeholder = "Create Password"
        field.leftView = outerView
        field.keyboardType = .default
        field.isSecureTextEntry = true

        return field
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    public var completion: (() -> Void)?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        addSubviews()
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        addButtonActions()
        addImageGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = 140
        
        profilePictureImageView.frame = CGRect(x: (view.width - imageSize) / 2, y: view.safeAreaInsets.top + 15, width: imageSize, height: imageSize)
        usernameField.frame = CGRect(x: 25, y: profilePictureImageView.bottom + 20, width: view.width - 50, height: 50)
        emailField.frame = CGRect(x: 25, y: usernameField.bottom + 10, width: view.width - 50, height: 50)
        passwordField.frame = CGRect(x: 25, y: emailField.bottom + 10, width: view.width - 50, height: 50)
        signUpButton.frame = CGRect(x: 35, y: passwordField.bottom + 20, width: view.width - 70, height: 50)
    }
    
    private func addSubviews() {
        view.addSubview(profilePictureImageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
    }
    
    private func addImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(tap)
    }
    
    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func didTapSignUp() {
        // dismiss keyboard when tapping the sign in button regardless of field the user is on
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty, // avoid spaces to count as valid inputs
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              username.trimmingCharacters(in: .alphanumerics).isEmpty, // avoid non alphamumeric characters
              username.count >= 2,
              password.count >= 6 else { // the text property is optional on a field
            
            presentError()
            return
        }
        
        // Sign up with AuthManager
        let data = profilePictureImageView.image?.pngData()
        AuthManager.shared.signUp(username: username, email: email, password: password, profilePicture: data) { [weak self] result in
            DispatchQueue.main.async { // UI operation has to be in main dispatch queue
                switch result {
                case .success(let user):
                    UserDefaults.standard.setValue(user.email, forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.completion?()
                case .failure(let error):
                    print("\n\nSign Up Error: \(error)")
                }
            }
        }
    }
    
    private func presentError() {
        let alert = UIAlertController(title: "Woops", message: "Please fill out and validate all fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func didTapImage() {
        let sheet = UIAlertController(title: "Profile Picture", message: "Set a profile picture", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        present(sheet, animated: true)
    }
    
    // MARK: Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder() // pressing enter/next on the username field, the cursor will move to the email field
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder() // pressing enter/next on the email field, the cursor will move to the password field
        } else {
            textField.resignFirstResponder() // pressing enter/next on the password field, the keyboard will be dismissed
            didTapSignUp()
        }
        return true
    }
    
    // Image Picker
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profilePictureImageView.image = image
    }
}

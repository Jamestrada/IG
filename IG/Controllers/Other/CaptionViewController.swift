//
//  CaptionViewController.swift
//  IG
//
//  Created by James Estrada on 6/7/21.
//

import UIKit

class CaptionViewController: UIViewController, UITextViewDelegate {
    
    private let image: UIImage
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Add caption..."
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .systemFont(ofSize: 20)
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        return textView
    }()
    
    // MARK: - Init
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(textView)
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(didTapPost))
    }
    
    @objc func didTapPost() {
        textView.resignFirstResponder()
        var caption = textView.text ?? ""
        if caption == "Add caption..." {
            caption = ""
        }
        
        // Generate post ID
        guard let newPostID = createNewPostID() else {
            return
        }
        // Upload Post
        // Update Database
        
    }
    
    private func createNewPostID() -> String? {
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }
        return "\(username)_\(randomNumber)_\(timeStamp)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width / 4
        imageView.frame = CGRect(x: (view.width - size) / 2, y: view.safeAreaInsets.top + 10, width: size, height: size)
        textView.frame = CGRect(x: 20, y: imageView.bottom + 20, width: view.width - 40, height: 100)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add caption..." {
            textView.text = nil
        }
    }
}

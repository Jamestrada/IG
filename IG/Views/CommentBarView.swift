//
//  CommentBarView.swift
//  IG
//
//  Created by James Estrada on 7/21/21.
//

import UIKit

protocol CommentBarViewDelegate: AnyObject {
    func CommentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String)
}

final class CommentBarView: UIView, UITextFieldDelegate{
    
    weak var delegate: CommentBarViewDelegate?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    private let field: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Comment"
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(button)
        addSubview(field)
        field.delegate = self
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        backgroundColor = .tertiarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func didTapComment() {
        guard let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        delegate?.CommentBarViewDidTapDone(self, withText: text)
        field.resignFirstResponder()
        field.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.sizeToFit()
        button.frame = CGRect(x: width - button.width - 6, y: (height - button.height) / 2, width: button.width + 4, height: button.height)
        field.frame = CGRect(x: 2, y: (height - 50) / 2, width: width - button.width - 12, height: 50)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        didTapComment()
        return true
    }
}

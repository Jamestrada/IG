//
//  ProfileHeaderCountView.swift
//  IG
//
//  Created by James Estrada on 7/1/21.
//

import UIKit

class ProfileHeaderCountView: UIView {
    
    // Count Buttons
    
    private let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("0\nFollowers", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("0\nFollowing", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("0\nPosts", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(followerCountButton)
        addSubview(followingCountButton)
        addSubview(postCountButton)
        addSubview(actionButton)
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addActions() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth: CGFloat = (width - 15) / 3
        followerCountButton.frame = CGRect(x: 5, y: 5, width: buttonWidth, height: height / 2)
        followingCountButton.frame = CGRect(x: followerCountButton.right + 5, y: 5, width: buttonWidth, height: height / 2)
        postCountButton.frame = CGRect(x: followingCountButton.right + 5, y: 5, width: buttonWidth, height: height / 2)
        actionButton.frame = CGRect(x: 5, y: height - 42, width: width - 10, height: 40)
    }
}

//
//  NewConversationCell.swift
//  IG
//
//  Created by James Estrada on 9/23/21.
//

import Foundation
import SDWebImage

class NewConversationCell: UITableViewCell {
    
    static let identifier = "NewConversationCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 70, height: 70)
        usernameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 20,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: 50)
    }
    
    public func configure(with model: Conversation) {
        usernameLabel.text = model.targetUser.username
        
        StorageManager.shared.profilePictureURL(for: model.targetUser.username) {[weak self] url in
            DispatchQueue.main.async {
                self?.userImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
}

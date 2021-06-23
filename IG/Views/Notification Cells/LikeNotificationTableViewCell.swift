//
//  LikeNotificationTableViewCell.swift
//  IG
//
//  Created by James Estrada on 6/20/21.
//

import UIKit

class LikeNotificationTableViewCell: UITableViewCell {
    static let identifier = "LikeNotificationTableViewCell"
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(postImageView)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height / 1.5
        profilePictureImageView.frame = CGRect(x: 10, y: (contentView.height - imageSize) / 2, width: imageSize, height: imageSize)
        profilePictureImageView.layer.cornerRadius = imageSize / 2
        
        let postSize: CGFloat = contentView.height - 20
        postImageView.frame = CGRect(x: contentView.width - postSize - 10, y: 10, width: postSize, height: postSize)
        
        let labelSize = label.sizeThatFits(CGSize(width: contentView.width - profilePictureImageView.right - 25 - postSize, height: contentView.height))
        label.frame = CGRect(x: profilePictureImageView.right + 10, y: 0, width: labelSize.width, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePictureImageView.image = nil
        postImageView.image = nil
        label.text = nil
    }
    
    public func configure(with viewModel: LikeNotificationCellViewModel) {
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        postImageView.sd_setImage(with: viewModel.postUrl, completed: nil)
        label.text = "\(viewModel.username) liked your post."
    }
}

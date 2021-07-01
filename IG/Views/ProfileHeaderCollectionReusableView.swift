//
//  ProfileHeaderCollectionReusableView.swift
//  IG
//
//  Created by James Estrada on 6/30/21.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileHeaderCollectionReusableView"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let countContainerView = ProfileHeaderCountView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(countContainerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = width / 3.5
        imageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize / 2
        countContainerView.frame = CGRect(x: imageView.right + 5, y: 3, width: width - imageView.right - 10, height: imageSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    public func configure(with viewModel: ProfileHeaderViewModel) {
        
    }
}

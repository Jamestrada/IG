//
//  PostDatetimeCollectionViewCell.swift
//  IG
//
//  Created by James Estrada on 5/28/21.
//

import UIKit

final class PostDatetimeCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostDatetimeCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true // avoid anything to overflow the content
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 12, y: 0, width: contentView.width - 12, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: PostDatetimeCollectionViewCellViewModel) {
        let date = viewModel.date
        label.text = .date(from: date)
    }
}

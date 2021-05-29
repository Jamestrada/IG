//
//  PosterCollectionViewCell.swift
//  IG
//
//  Created by James Estrada on 5/28/21.
//

import UIKit

final class PosterCollectionViewCell: UICollectionViewCell {
    static let identifier = "PosterCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true // avoid anything to overflow the content
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PosterCollectionViewCellViewModel) {
        
    }
}

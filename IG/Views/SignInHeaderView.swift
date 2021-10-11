//
//  SignInHeaderView.swift
//  IG
//
//  Created by James Estrada on 5/11/21.
//

import UIKit

class SignInHeaderView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "white_logo")
        imageView.contentMode = .scaleAspectFit // fit in the frame
        return imageView
    }()
    private var gradientLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        createGradient()
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func createGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor]
        self.gradientLayer = gradientLayer
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = layer.bounds
        imageView.frame = CGRect(x: width / 4, y: 20, width: width / 2, height: height - 40)
    }
}

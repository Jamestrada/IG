//
//  IGTextField.swift
//  IG
//
//  Created by James Estrada on 5/13/21.
//

import UIKit

class IGTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        leftViewMode = .always
        returnKeyType = .next
        autocorrectionType = .no
        layer.cornerRadius = 8
        layer.borderWidth = 1
        backgroundColor = .secondarySystemBackground
        layer.borderColor = UIColor.secondaryLabel.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

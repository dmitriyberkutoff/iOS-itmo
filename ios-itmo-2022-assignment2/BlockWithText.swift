//
//  BlockWithText.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 12.10.2022.
//

import UIKit

class NamedField: UIView, UITextFieldDelegate {
    weak var delegate: EditingDelegate?
    
    private var minLen = 1
    private var maxLen = 100
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = label.font.withSize(12)
        return label
    }()
    
    public lazy var textField: UITextField = {
        let name = UITextField()
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 20))
        name.leftView = paddingView
        name.leftViewMode = .always
        name.translatesAutoresizingMaskIntoConstraints = false
        name.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        name.borderStyle = .roundedRect
        name.layer.cornerRadius = 8
        return name
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureView(conf_label: String, conf_text: String, minL: Int = 1, maxL: Int = 100) {
        label.text = conf_label
        textField.placeholder = conf_text
        maxLen = maxL
        minLen = minL
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        addSubview(textField)
        
        textField.addTarget(self, action: #selector(validation), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 52),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc
    func validation() {
        if let t = textField.text {
            if t.count > maxLen || t.count < minLen {
                textField.layer.borderWidth = 1.0
                textField.layer.borderColor = UIColor.systemRed.cgColor
                label.textColor = .systemRed
                delegate?.disableSave()
                return
            } else {
                textField.layer.borderWidth = 0
                label.textColor = .systemGray
            }
        }
        delegate?.didChangeValidation()
    }
}

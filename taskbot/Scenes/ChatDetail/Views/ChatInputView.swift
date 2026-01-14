//
//  ChatInputView.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatInputView: UIView {
    var onSendMessage: ((String) -> Void)?
    var onAttachmentTapped: (() -> Void)?
    var onStickerTapped: (() -> Void)?
    var onLocationTapped: (() -> Void)?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.18, alpha: 1)
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Напишите сообщение"
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .white
        textField.tintColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "Напишите сообщение",
            attributes: [.foregroundColor: UIColor(white: 0.5, alpha: 1)]
        )
        textField.delegate = self
        textField.returnKeyType = .send
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var attachButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "doc.on.doc", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(white: 0.6, alpha: 1)
        button.addTarget(self, action: #selector(attachTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stickerButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "face.smiling", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(white: 0.6, alpha: 1)
        button.addTarget(self, action: #selector(stickerTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "location.circle", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(white: 0.6, alpha: 1)
        button.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [attachButton, stickerButton, locationButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1)
        
        addSubview(containerView)
        containerView.addSubview(textField)
        containerView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor, constant: -12),
            
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonsStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    @objc private func attachTapped() {
        onAttachmentTapped?()
    }
    
    @objc private func stickerTapped() {
        onStickerTapped?()
    }
    
    @objc private func locationTapped() {
        onLocationTapped?()
    }
    
    private func sendMessage() {
        guard let text = textField.text, !text.isEmpty else { return }
        onSendMessage?(text)
        textField.text = ""
    }
}

extension ChatInputView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return false
    }
}
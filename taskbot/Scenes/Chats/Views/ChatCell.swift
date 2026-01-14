//
//  ChatCell.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatCell: UITableViewCell {
    static let identifier = "ChatCell"
    
    private var avatarLoadTask: URLSessionDataTask?
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var onlineIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1).cgColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private lazy var verifiedBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.seal.fill")
        imageView.tintColor = UIColor(red: 0.2, green: 0.6, blue: 1, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var unreadBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(onlineIndicator)
        contentView.addSubview(nameStackView)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(unreadBadge)
        
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(verifiedBadge)
        
        unreadBadge.addSubview(unreadCountLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),
            onlineIndicator.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            onlineIndicator.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            onlineIndicator.widthAnchor.constraint(equalToConstant: 12),
            onlineIndicator.heightAnchor.constraint(equalToConstant: 12),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 16),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 16),
            nameStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameStackView.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),
            lastMessageLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            lastMessageLabel.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 4),
            lastMessageLabel.trailingAnchor.constraint(equalTo: unreadBadge.leadingAnchor, constant: -8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.centerYAnchor.constraint(equalTo: nameStackView.centerYAnchor),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            unreadBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unreadBadge.centerYAnchor.constraint(equalTo: lastMessageLabel.centerYAnchor),
            unreadBadge.heightAnchor.constraint(equalToConstant: 20),
            unreadBadge.widthAnchor.constraint(equalToConstant: 20),
            unreadCountLabel.topAnchor.constraint(equalTo: unreadBadge.topAnchor),
            unreadCountLabel.bottomAnchor.constraint(equalTo: unreadBadge.bottomAnchor),
            unreadCountLabel.leadingAnchor.constraint(equalTo: unreadBadge.leadingAnchor, constant: 6),
            unreadCountLabel.trailingAnchor.constraint(equalTo: unreadBadge.trailingAnchor, constant: -6)
        ])
    }
    
    func configure(with viewModel: ChatViewModel) {
        avatarLoadTask?.cancel()
        avatarImageView.image = nil
        nameLabel.text = viewModel.userName
        lastMessageLabel.text = viewModel.lastMessage
        timeLabel.text = viewModel.timeAgo
        
        verifiedBadge.isHidden = !viewModel.isVerified
        onlineIndicator.isHidden = !viewModel.isOnline
        
        if viewModel.unreadCount > 0 {
            unreadBadge.isHidden = false
            unreadCountLabel.text = "\(viewModel.unreadCount)"
        } else {
            unreadBadge.isHidden = true
        }
        if let urlString = viewModel.avatarURL,
           let url = URL(string: urlString) {
            avatarLoadTask = ImageLoader.shared.loadImage(from: url) { [weak self] image in
                self?.avatarImageView.image = image
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarLoadTask?.cancel()
        avatarImageView.image = nil
        nameLabel.text = nil
        lastMessageLabel.text = nil
        timeLabel.text = nil
        verifiedBadge.isHidden = true
        onlineIndicator.isHidden = true
        unreadBadge.isHidden = true
    }
}

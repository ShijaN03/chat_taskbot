//
//  UserCell.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class UserCell: UITableViewCell {
    static let identifier = "UserCell"
    
    private var avatarLoadTask: URLSessionDataTask?
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    private lazy var accountTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
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
        contentView.addSubview(nameStackView)
        contentView.addSubview(accountTypeLabel)
        
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(verifiedBadge)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 16),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 16),
            nameStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            accountTypeLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            accountTypeLabel.topAnchor.constraint(equalTo: nameStackView.bottomAnchor, constant: 2),
            accountTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with viewModel: UserViewModel) {
        avatarLoadTask?.cancel()
        avatarImageView.image = nil
        
        nameLabel.text = viewModel.username
        accountTypeLabel.text = viewModel.accountType
        verifiedBadge.isHidden = !viewModel.isVerified
        
        if let urlString = viewModel.avatarURL, let url = URL(string: urlString) {
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
        accountTypeLabel.text = nil
        verifiedBadge.isHidden = true
    }
}
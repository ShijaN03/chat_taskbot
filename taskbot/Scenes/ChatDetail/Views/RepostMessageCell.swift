//
//  RepostMessageCell.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class RepostMessageCell: UITableViewCell {
    static let identifier = "RepostMessageCell"
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var repostCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var playIconView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        imageView.image = UIImage(systemName: "play.fill", withConfiguration: config)
        imageView.tintColor = .white
        imageView.contentMode = .center
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userInfoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var repostUserAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var repostUserNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private lazy var repostTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.text = "Публикация"
        return label
    }()
    
    private lazy var dateHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    
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
        
        contentView.addSubview(dateHeaderLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(repostCardView)
        repostCardView.addSubview(thumbnailImageView)
        repostCardView.addSubview(playIconView)
        repostCardView.addSubview(repostUserAvatarImageView)
        repostCardView.addSubview(userInfoStackView)
        
        userInfoStackView.addArrangedSubview(repostUserNameLabel)
        userInfoStackView.addArrangedSubview(repostTypeLabel)
        
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            dateHeaderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateHeaderLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            
            bubbleView.topAnchor.constraint(equalTo: dateHeaderLabel.bottomAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(equalToConstant: 220),
            
            repostCardView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            repostCardView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            repostCardView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            repostCardView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            thumbnailImageView.topAnchor.constraint(equalTo: repostCardView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: repostCardView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: repostCardView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 160),
            
            playIconView.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 48),
            playIconView.heightAnchor.constraint(equalToConstant: 48),
            
            repostUserAvatarImageView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            repostUserAvatarImageView.leadingAnchor.constraint(equalTo: repostCardView.leadingAnchor, constant: 8),
            repostUserAvatarImageView.widthAnchor.constraint(equalToConstant: 24),
            repostUserAvatarImageView.heightAnchor.constraint(equalToConstant: 24),
            repostUserAvatarImageView.bottomAnchor.constraint(equalTo: repostCardView.bottomAnchor, constant: -8),
            
            userInfoStackView.leadingAnchor.constraint(equalTo: repostUserAvatarImageView.trailingAnchor, constant: 8),
            userInfoStackView.centerYAnchor.constraint(equalTo: repostUserAvatarImageView.centerYAnchor),
            userInfoStackView.trailingAnchor.constraint(lessThanOrEqualTo: repostCardView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with viewModel: MessageViewModel) {
        if viewModel.showDateHeader, let date = viewModel.date {
            dateHeaderLabel.text = date
            dateHeaderLabel.isHidden = false
        } else {
            dateHeaderLabel.isHidden = true
        }
        if let repost = viewModel.repostInfo {
            repostUserNameLabel.text = repost.userName
            playIconView.isHidden = !repost.isVideo
            if let _ = URL(string: repost.mediaURL) {
            }
        }
        if viewModel.isOutgoing {
            avatarImageView.isHidden = true
            bubbleLeadingConstraint.isActive = false
            bubbleTrailingConstraint.isActive = true
        } else {
            if viewModel.showAvatar {
                avatarImageView.isHidden = false
            } else {
                avatarImageView.isHidden = true
            }
            bubbleTrailingConstraint.isActive = false
            bubbleLeadingConstraint.isActive = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        repostUserAvatarImageView.image = nil
        avatarImageView.image = nil
        avatarImageView.isHidden = true
        dateHeaderLabel.isHidden = true
        playIconView.isHidden = true
    }
}
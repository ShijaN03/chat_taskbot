//
//  MediaMessageCell.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class MediaMessageCell: UITableViewCell {
    static let identifier = "MediaMessageCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mediaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1)
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0, alpha: 0.5)
        button.layer.cornerRadius = 25
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var repostLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var repostIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        imageView.image = UIImage(systemName: "play.rectangle.fill", withConfiguration: config)
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    private lazy var reactionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var containerLeadingConstraint: NSLayoutConstraint!
    private var containerTrailingConstraint: NSLayoutConstraint!
    
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
        contentView.addSubview(containerView)
        containerView.addSubview(mediaImageView)
        containerView.addSubview(playButton)
        containerView.addSubview(repostLabel)
        containerView.addSubview(repostIcon)
        contentView.addSubview(reactionLabel)
        
        containerLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56)
        containerTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            dateHeaderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateHeaderLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: dateHeaderLabel.bottomAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 280),
            
            mediaImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mediaImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mediaImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mediaImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: mediaImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: mediaImageView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            repostLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            repostLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            
            repostIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            repostIcon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            reactionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            reactionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8)
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
            repostLabel.text = repost.userName
            repostLabel.isHidden = false
            
            if repost.isVideo {
                playButton.isHidden = false
                repostIcon.isHidden = false
            } else {
                playButton.isHidden = true
                repostIcon.isHidden = true
            }
        } else {
            repostLabel.isHidden = true
            playButton.isHidden = viewModel.type != .video
            repostIcon.isHidden = true
        }
        if viewModel.isOutgoing {
            containerLeadingConstraint.isActive = false
            containerTrailingConstraint.isActive = true
        } else {
            containerTrailingConstraint.isActive = false
            containerLeadingConstraint.isActive = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mediaImageView.image = nil
        playButton.isHidden = true
        repostLabel.isHidden = true
        repostIcon.isHidden = true
        dateHeaderLabel.isHidden = true
        reactionLabel.isHidden = true
    }
}
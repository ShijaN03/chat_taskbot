//
//  OnboardingPageView.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class OnboardingPageView: UIView {
    
    private var pageIndex: Int = 0
    
    // Container for all decorative elements
    private lazy var decorationsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(decorationsContainer)
        addSubview(progressImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            decorationsContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            decorationsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            decorationsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            decorationsContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.55),
            
            progressImageView.topAnchor.constraint(equalTo: decorationsContainer.bottomAnchor, constant: 16),
            progressImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressImageView.heightAnchor.constraint(equalToConstant: 10),
            
            titleLabel.topAnchor.constraint(equalTo: progressImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }
    
    func configure(with data: OnboardingPageData, pageIndex: Int) {
        self.pageIndex = pageIndex
        titleLabel.text = data.title
        descriptionLabel.text = data.description
        
        decorationsContainer.subviews.forEach { $0.removeFromSuperview() }
        
        switch pageIndex {
        case 0:
            setupPage1()
        case 1:
            setupPage2()
        case 2:
            setupPage3()
        case 3:
            setupPage4()
        default:
            break
        }
    }
    
    private func setupPage1() {
        progressImageView.image = UIImage(named: "ob1_progress")
        
        let headphonesView = createImageView(named: "ob1_headphones")
        let flowerView = createImageView(named: "ob1_flower")
        let starView = createImageView(named: "ob1_star")
        let circleView = createImageView(named: "ob1_circle")
        
        decorationsContainer.addSubview(starView)
        decorationsContainer.addSubview(headphonesView)
        decorationsContainer.addSubview(flowerView)
        decorationsContainer.addSubview(circleView)
        
        NSLayoutConstraint.activate([
            // Star (right side, large white)
            starView.trailingAnchor.constraint(equalTo: decorationsContainer.trailingAnchor, constant: -20),
            starView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: 20),
            starView.widthAnchor.constraint(equalToConstant: 160),
            starView.heightAnchor.constraint(equalToConstant: 160),
            
            // Headphones (left side)
            headphonesView.leadingAnchor.constraint(equalTo: decorationsContainer.leadingAnchor, constant: 30),
            headphonesView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 60),
            headphonesView.widthAnchor.constraint(equalToConstant: 140),
            headphonesView.heightAnchor.constraint(equalToConstant: 140),
            
            // Flower (top right of headphones)
            flowerView.leadingAnchor.constraint(equalTo: headphonesView.trailingAnchor, constant: -20),
            flowerView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 40),
            flowerView.widthAnchor.constraint(equalToConstant: 50),
            flowerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Circle (under headphones)
            circleView.leadingAnchor.constraint(equalTo: headphonesView.leadingAnchor, constant: 20),
            circleView.topAnchor.constraint(equalTo: headphonesView.bottomAnchor, constant: -30),
            circleView.widthAnchor.constraint(equalToConstant: 80),
            circleView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Page 2: Photo with hearts, wave, message
    private func setupPage2() {
        progressImageView.image = UIImage(named: "ob2_progress")
        
        let waveView = createImageView(named: "ob2_wave")
        let imageView = createImageView(named: "ob2_image")
        let heartBoldView = createImageView(named: "ob2_heart_bold")
        let heartThinView = createImageView(named: "ob2_heart_thin")
        let messageView = createImageView(named: "ob2_message")
        
        decorationsContainer.addSubview(waveView)
        decorationsContainer.addSubview(imageView)
        decorationsContainer.addSubview(heartBoldView)
        decorationsContainer.addSubview(heartThinView)
        decorationsContainer.addSubview(messageView)
        
        NSLayoutConstraint.activate([
            // Wave (background, full width)
            waveView.leadingAnchor.constraint(equalTo: decorationsContainer.leadingAnchor),
            waveView.trailingAnchor.constraint(equalTo: decorationsContainer.trailingAnchor),
            waveView.bottomAnchor.constraint(equalTo: decorationsContainer.bottomAnchor),
            waveView.heightAnchor.constraint(equalToConstant: 180),
            
            // Photo (centered)
            imageView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 220),
            imageView.heightAnchor.constraint(equalToConstant: 220),
            
            // Hearts (left side)
            heartBoldView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            heartBoldView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 20),
            heartBoldView.widthAnchor.constraint(equalToConstant: 60),
            heartBoldView.heightAnchor.constraint(equalToConstant: 80),
            
            heartThinView.trailingAnchor.constraint(equalTo: heartBoldView.leadingAnchor, constant: 15),
            heartThinView.topAnchor.constraint(equalTo: heartBoldView.bottomAnchor, constant: -30),
            heartThinView.widthAnchor.constraint(equalToConstant: 40),
            heartThinView.heightAnchor.constraint(equalToConstant: 50),
            
            // Message (top right)
            messageView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -20),
            messageView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 30),
            messageView.widthAnchor.constraint(equalToConstant: 70),
            messageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Page 3: Photo with wave, spiral, star
    private func setupPage3() {
        progressImageView.image = UIImage(named: "ob3_progress")
        
        let blueStarView = createImageView(named: "ob3_bluestar")
        let imageView = createImageView(named: "ob3_image")
        let spiralView = createImageView(named: "ob3_spiral")
        let starView = createImageView(named: "ob3_star")
        
        decorationsContainer.addSubview(blueStarView)
        decorationsContainer.addSubview(imageView)
        decorationsContainer.addSubview(spiralView)
        decorationsContainer.addSubview(starView)
        
        NSLayoutConstraint.activate([
            // Blue wave/star (top)
            blueStarView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 30),
            blueStarView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor, constant: 20),
            blueStarView.widthAnchor.constraint(equalToConstant: 200),
            blueStarView.heightAnchor.constraint(equalToConstant: 80),
            
            // Photo (centered)
            imageView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Spiral (left bottom)
            spiralView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 30),
            spiralView.topAnchor.constraint(equalTo: imageView.centerYAnchor, constant: -20),
            spiralView.widthAnchor.constraint(equalToConstant: 100),
            spiralView.heightAnchor.constraint(equalToConstant: 120),
            
            // White star (right bottom)
            starView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -40),
            starView.topAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 10),
            starView.widthAnchor.constraint(equalToConstant: 100),
            starView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Page 4: Shopping woman with stars
    private func setupPage4() {
        progressImageView.image = UIImage(named: "ob4_progress")
        
        let blueStarView = createImageView(named: "ob4_bluestar")
        let imageView = createImageView(named: "ob4_image")
        let whiteStarView = createImageView(named: "ob4_whitestar")
        
        decorationsContainer.addSubview(blueStarView)
        decorationsContainer.addSubview(imageView)
        decorationsContainer.addSubview(whiteStarView)
        
        NSLayoutConstraint.activate([
            // Blue star (top left)
            blueStarView.leadingAnchor.constraint(equalTo: decorationsContainer.leadingAnchor, constant: 20),
            blueStarView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 40),
            blueStarView.widthAnchor.constraint(equalToConstant: 120),
            blueStarView.heightAnchor.constraint(equalToConstant: 120),
            
            // Photo (centered)
            imageView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 240),
            
            // White star (right)
            whiteStarView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -50),
            whiteStarView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 40),
            whiteStarView.widthAnchor.constraint(equalToConstant: 120),
            whiteStarView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func createImageView(named: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: named)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

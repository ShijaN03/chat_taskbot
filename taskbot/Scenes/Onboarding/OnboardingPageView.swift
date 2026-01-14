//
//  OnboardingPageView.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class OnboardingPageView: UIView {
    
    private var pageIndex: Int = 0
    
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
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true 
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
            decorationsContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50),
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
            starView.trailingAnchor.constraint(equalTo: decorationsContainer.trailingAnchor, constant: 20),
            starView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: 20),
            starView.widthAnchor.constraint(equalToConstant: 270),
            starView.heightAnchor.constraint(equalToConstant: 270),
            
            headphonesView.leadingAnchor.constraint(equalTo: decorationsContainer.leadingAnchor, constant: 30),
            headphonesView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 60),
            headphonesView.widthAnchor.constraint(equalToConstant: 200),
            headphonesView.heightAnchor.constraint(equalToConstant: 200),
            
            flowerView.leadingAnchor.constraint(equalTo: headphonesView.trailingAnchor, constant: -80),
            flowerView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 40),
            flowerView.widthAnchor.constraint(equalToConstant: 70),
            flowerView.heightAnchor.constraint(equalToConstant: 70),
            
            circleView.leadingAnchor.constraint(equalTo: headphonesView.leadingAnchor, constant: 80),
            circleView.topAnchor.constraint(equalTo: headphonesView.bottomAnchor, constant: -15),
            circleView.widthAnchor.constraint(equalToConstant: 100),
            circleView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
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
            waveView.leadingAnchor.constraint(equalTo: decorationsContainer.leadingAnchor),
            waveView.trailingAnchor.constraint(equalTo: decorationsContainer.trailingAnchor),
            waveView.bottomAnchor.constraint(equalTo: decorationsContainer.bottomAnchor),
            waveView.heightAnchor.constraint(equalToConstant: 400),
            
            imageView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 290),
            imageView.heightAnchor.constraint(equalToConstant: 260),
            
            heartBoldView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
            heartBoldView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 40),
            heartBoldView.widthAnchor.constraint(equalToConstant: 50),
            heartBoldView.heightAnchor.constraint(equalToConstant: 60),
            
            heartThinView.trailingAnchor.constraint(equalTo: heartBoldView.leadingAnchor, constant: 90),
            heartThinView.topAnchor.constraint(equalTo: heartBoldView.bottomAnchor, constant: -140),
            heartThinView.widthAnchor.constraint(equalToConstant: 80),
            heartThinView.heightAnchor.constraint(equalToConstant: 100),
            
            messageView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -80),
            messageView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 60),
            messageView.widthAnchor.constraint(equalToConstant: 140),
            messageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
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
            blueStarView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 30),
            blueStarView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor, constant: 20),
            blueStarView.widthAnchor.constraint(equalToConstant: 600),
            blueStarView.heightAnchor.constraint(equalToConstant: 300),
            
            imageView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            spiralView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 60),
            spiralView.topAnchor.constraint(equalTo: imageView.centerYAnchor, constant: -20),
            spiralView.widthAnchor.constraint(equalToConstant: 150),
            spiralView.heightAnchor.constraint(equalToConstant: 250),
            
            starView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -100),
            starView.topAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 30),
            starView.widthAnchor.constraint(equalToConstant: 150),
            starView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupPage4() {
        progressImageView.image = UIImage(named: "ob4_progress")
        
        let blueStarView = createImageView(named: "ob4_bluestar")
        let imageView = createImageView(named: "ob4_image")
        let whiteStarView = createImageView(named: "ob4_whitestar")
        
        decorationsContainer.addSubview(imageView)
        decorationsContainer.addSubview(blueStarView)
        decorationsContainer.addSubview(whiteStarView)
        
        NSLayoutConstraint.activate([
            blueStarView.leadingAnchor.constraint(equalTo: decorationsContainer.leadingAnchor, constant: 20),
            blueStarView.topAnchor.constraint(equalTo: decorationsContainer.topAnchor, constant: 40),
            blueStarView.widthAnchor.constraint(equalToConstant: 160),
            blueStarView.heightAnchor.constraint(equalToConstant: 160),
            
            imageView.centerXAnchor.constraint(equalTo: decorationsContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: decorationsContainer.centerYAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            whiteStarView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -150),
            whiteStarView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 80),
            whiteStarView.widthAnchor.constraint(equalToConstant: 240),
            whiteStarView.heightAnchor.constraint(equalToConstant: 240)
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

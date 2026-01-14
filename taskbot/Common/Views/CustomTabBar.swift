//
//  CustomTabBar.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(_ index: Int)
}

final class CustomTabBar: UIView {
    
    weak var delegate: CustomTabBarDelegate?
    private var selectedIndex: Int = 3

    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.layer.cornerRadius = 32
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var homeButton: UIButton = createTabButton(
        icon: "tb1",
        tag: 0
    )
    
    private lazy var heartButton: UIButton = createTabButton(
        icon: "tb2",
        tag: 1
    )
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 0.95, alpha: 1)
        button.layer.cornerRadius = 16
        button.tag = 2
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var chatsButton: UIButton = createTabButton(
        icon: "tb4",
        tag: 3
    )
    
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(white: 0.3, alpha: 1)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.tag = 4
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.setImage(UIImage(systemName: "person.fill", withConfiguration: config), for: .normal)
        button.tintColor = .gray
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateSelection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(homeButton)
        stackView.addArrangedSubview(heartButton)
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(chatsButton)
        stackView.addArrangedSubview(profileButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            homeButton.widthAnchor.constraint(equalToConstant: 24),
            homeButton.heightAnchor.constraint(equalToConstant: 24),
            
            heartButton.widthAnchor.constraint(equalToConstant: 24),
            heartButton.heightAnchor.constraint(equalToConstant: 24),
            
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32),
            
            chatsButton.widthAnchor.constraint(equalToConstant: 24),
            chatsButton.heightAnchor.constraint(equalToConstant: 24),
            
            profileButton.widthAnchor.constraint(equalToConstant: 24),
            profileButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func createTabButton(icon: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(named: icon), for: .normal)
        button.tintColor = .gray
        button.tag = tag
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc private func tabTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index == 3 else { return }
        
        selectedIndex = index
        updateSelection()
        delegate?.didSelectTab(index)
    }
    
    private func updateSelection() {
        let buttons = [homeButton, heartButton, chatsButton]
        
        for button in buttons {
            button.tintColor = button.tag == selectedIndex ? .white : .gray
        }
    }
    
    func setProfileImage(_ image: UIImage?) {
        if let image = image {
            profileButton.setImage(image, for: .normal)
        }
    }
    
    func selectTab(_ index: Int) {
        selectedIndex = index
        updateSelection()
    }
}

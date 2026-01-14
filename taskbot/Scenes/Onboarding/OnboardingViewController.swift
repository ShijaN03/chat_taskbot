//
//  OnboardingViewController.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class OnboardingViewController: UIViewController {
    var router: OnboardingRouter?
    
    private var currentPage = 0
    private let pages: [OnboardingPageData] = [
        OnboardingPageData(
            imageName: "onboarding_1",
            title: "Смотрите ваших блогеров",
            description: "Тут какое-то описание в пару строчек как классно можно делать что-то",
            showsPhoto: false
        ),
        OnboardingPageData(
            imageName: "onboarding_2",
            title: "Общайтесь с друзьями",
            description: "Тут какое-то описание в пару строчек как классно можно делать что-то",
            showsPhoto: true
        ),
        OnboardingPageData(
            imageName: "onboarding_3",
            title: "Делайте покупки в маркете",
            description: "Тут какое-то описание в пару строчек как классно можно делать что-то",
            showsPhoto: true
        ),
        OnboardingPageData(
            imageName: "onboarding_4",
            title: "Участвуйте в акциях",
            description: "Тут какое-то описание в пару строчек как классно можно делать что-то",
            showsPhoto: true,
            isLastPage: true
        )
    ]
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Далее", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.25, green: 0.45, blue: 0.95, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Пропустить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPages()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -12),
            
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            skipButton.heightAnchor.constraint(equalToConstant: 50),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupPages() {
        for (index, page) in pages.enumerated() {
            let pageView = OnboardingPageView()
            pageView.configure(with: page, pageIndex: index)
            pageView.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(pageView)
            
            NSLayoutConstraint.activate([
                pageView.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        }
    }
    
    private func updateUI(for page: Int) {
        pageControl.currentPage = page
        
        if pages[page].isLastPage {
            nextButton.setTitle("Зарегистрироваться", for: .normal)
            skipButton.isHidden = true
        } else {
            nextButton.setTitle("Далее", for: .normal)
            skipButton.isHidden = false
        }
    }
    
    @objc private func nextTapped() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            let offset = CGFloat(currentPage) * view.frame.width
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
            updateUI(for: currentPage)
        } else {
            router?.navigateToLogin()
        }
    }
    
    @objc private func skipTapped() {
        currentPage = pages.count - 1
        let offset = CGFloat(currentPage) * view.frame.width
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        updateUI(for: currentPage)
    }
}
extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / view.frame.width)
        currentPage = page
        updateUI(for: page)
    }
}
struct OnboardingPageData {
    let imageName: String
    let title: String
    let description: String
    let showsPhoto: Bool
    var isLastPage: Bool = false
}
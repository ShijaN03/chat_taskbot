//
//  OnboardingRouter.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class OnboardingRouter {
    
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let view = OnboardingViewController()
        let router = OnboardingRouter()
        
        view.router = router
        router.viewController = view
        
        return view
    }
    
    func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        viewController?.present(loginVC, animated: true)
    }
    
    func navigateToMainApp() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        guard let windowScene = viewController?.view.window?.windowScene,
              let window = windowScene.windows.first else { return }
        
        let chatsVC = ChatsRouter.createModule()
        let navController = UINavigationController(rootViewController: chatsVC)
        navController.navigationBar.isHidden = true
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = navController
        }
    }
}
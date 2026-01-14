//
//  SceneDelegate.swift
//  taskbot
//
//  Created by shijan on 10.01.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let keychain = KeychainService.shared
        
        if keychain.isAuthenticated {
            showMainApp()
        } else {
            let onboardingVC = OnboardingRouter.createModule()
            window?.rootViewController = onboardingVC
        }
        
        window?.makeKeyAndVisible()
        initializeSessionIfNeeded()
    }
    
    private func showMainApp() {
        let chatsVC = ChatsRouter.createModule()
        let navController = UINavigationController(rootViewController: chatsVC)
        navController.navigationBar.isHidden = true
        window?.rootViewController = navController
    }
    
    private func initializeSessionIfNeeded() {
        Task {
            let authManager = AuthManager.shared
            if !authManager.hasSession {
                do {
                    _ = try await authManager.getAnonymousSession()
                    print("Anonymous session initialized")
                } catch {
                    print("Failed to initialize session: \(error)")
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {



    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {


    }


}

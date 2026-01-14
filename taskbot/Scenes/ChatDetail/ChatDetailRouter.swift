//
//  ChatDetailRouter.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatDetailRouter: ChatDetailRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule(chatId: String, userName: String, avatarURL: String?) -> UIViewController {
        let view = ChatDetailViewController()
        let presenter = ChatDetailPresenter(chatId: chatId, userName: userName, avatarURL: avatarURL)
        let interactor = ChatDetailInteractor()
        let router = ChatDetailRouter()
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func navigateToUserProfile(userId: String) {
        print("Navigate to user profile: \(userId)")
    }
    
    func presentImagePicker() {
    }
    
    func presentLocationPicker() {
    }
}
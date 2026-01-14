//
//  NewMessageRouter.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class NewMessageRouter: NewMessageRouterProtocol {
    
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let view = NewMessageViewController()
        let presenter = NewMessagePresenter()
        let interactor = NewMessageInteractor()
        let router = NewMessageRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToChat(with userId: Int, userName: String, avatarURL: String?) {
        let chatDetailVC = ChatDetailRouter.createModule(chatId: "\(userId)", userName: userName, avatarURL: avatarURL)
        viewController?.navigationController?.pushViewController(chatDetailVC, animated: true)
    }
}
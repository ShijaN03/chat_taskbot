//
//  ChatsRouter.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatsRouter: ChatsRouterProtocol {
    
    weak var viewController: UIViewController?
        
    static func createModule() -> UIViewController {
        let view = ChatsViewController()
        let presenter = ChatsPresenter()
        let interactor = ChatsInteractor()
        let router = ChatsRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToChat(with chatId: String, userName: String) {
        let chatDetailVC = ChatDetailRouter.createModule(chatId: chatId, userName: userName, avatarURL: nil)
        viewController?.navigationController?.pushViewController(chatDetailVC, animated: true)
    }
    
    func navigateToNewMessage() {
        let newMessageVC = NewMessageRouter.createModule()
        viewController?.navigationController?.pushViewController(newMessageVC, animated: true)
    }
}

//
//  NewMessageProtocols.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

protocol NewMessageViewProtocol: AnyObject {
    var presenter: NewMessagePresenterProtocol? { get set }
    
    func showUsers(_ users: [UserViewModel])
    func showRecommendations(_ users: [UserViewModel])
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
}

protocol NewMessagePresenterProtocol: AnyObject {
    var view: NewMessageViewProtocol? { get set }
    var interactor: NewMessageInteractorInputProtocol? { get set }
    var router: NewMessageRouterProtocol? { get set }
    
    func viewDidLoad()
    func didSearchUsers(with query: String)
    func didSelectUser(_ user: UserViewModel)
}

protocol NewMessageInteractorInputProtocol: AnyObject {
    var presenter: NewMessageInteractorOutputProtocol? { get set }
    
    func fetchRecommendedUsers()
    func searchUsers(with query: String)
}

protocol NewMessageInteractorOutputProtocol: AnyObject {
    func didFetchRecommendedUsers(_ users: [UserEntity])
    func didSearchUsers(_ users: [UserEntity])
    func didFailFetching(with error: Error)
}

protocol NewMessageRouterProtocol: AnyObject {
    var viewController: UIViewController? { get set }
    
    static func createModule() -> UIViewController
    func navigateToChat(with userId: String, userName: String)
}

struct UserViewModel {
    let id: String
    let username: String
    let displayName: String?
    let avatarURL: String?
    let accountType: String
    let isVerified: Bool
}

struct UserEntity {
    let id: String
    let username: String
    let displayName: String?
    let avatarURL: String?
    let accountType: AccountType
    let isVerified: Bool
}

enum AccountType {
    case personal
    case business
    case creator
    
    var displayName: String {
        switch self {
        case .personal: return "Личный аккаунт"
        case .business: return "Бизнес-аккаунт"
        case .creator: return "Аккаунт автора"
        }
    }
}
//
//  ChatDetailProtocols.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit
protocol ChatDetailViewProtocol: AnyObject {
    var presenter: ChatDetailPresenterProtocol? { get set }
    
    func showMessages(_ messages: [MessageViewModel])
    func appendMessage(_ message: MessageViewModel)
    func showUserInfo(name: String, status: String, avatarURL: String?)
    func showEmptyState(name: String, avatarURL: String?, registrationDate: String)
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    func scrollToBottom(animated: Bool)
}
protocol ChatDetailPresenterProtocol: AnyObject {
    var view: ChatDetailViewProtocol? { get set }
    var interactor: ChatDetailInteractorInputProtocol? { get set }
    var router: ChatDetailRouterProtocol? { get set }
    
    func viewDidLoad()
    func didTapBack()
    func didTapUserProfile()
    func didSendMessage(text: String)
    func didSendPhoto(image: UIImage)
    func didSendLocation(latitude: Double, longitude: Double)
    func didScrollToTop()
}
protocol ChatDetailInteractorInputProtocol: AnyObject {
    var presenter: ChatDetailInteractorOutputProtocol? { get set }
    
    func fetchMessages(chatId: String)
    func sendMessage(chatId: String, text: String)
    func sendPhoto(chatId: String, image: UIImage)
    func sendLocation(chatId: String, latitude: Double, longitude: Double)
    func loadMoreMessages(chatId: String, beforeId: String)
}
protocol ChatDetailInteractorOutputProtocol: AnyObject {
    func didFetchMessages(_ messages: [MessageEntity])
    func didSendMessage(_ message: MessageEntity)
    func didFailSendingMessage(with error: Error)
    func didLoadMoreMessages(_ messages: [MessageEntity])
}
protocol ChatDetailRouterProtocol: AnyObject {
    var viewController: UIViewController? { get set }
    
    static func createModule(chatId: String, userName: String, avatarURL: String?) -> UIViewController
    func navigateBack()
    func navigateToUserProfile(userId: String)
    func presentImagePicker()
    func presentLocationPicker()
}
struct MessageEntity {
    let id: String
    let senderId: String
    let isOutgoing: Bool
    let type: MessageType
    let content: String
    let mediaURL: String?
    let thumbnailURL: String?
    let createdAt: Date
    let isRead: Bool
    let repostInfo: RepostInfo?
}

struct RepostInfo {
    let userName: String
    let mediaURL: String
    let isVideo: Bool
}

enum MessageType {
    case text
    case photo
    case video
    case voice
    case location
    case repost
}
struct MessageViewModel {
    let id: String
    let isOutgoing: Bool
    let type: MessageType
    let text: String?
    let mediaURL: String?
    let thumbnailURL: String?
    let time: String
    let date: String?
    let showDateHeader: Bool
    let repostInfo: RepostInfo?
    let avatarURL: String?
    let showAvatar: Bool
}
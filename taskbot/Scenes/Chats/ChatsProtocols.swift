//
//  ChatsProtocols.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

protocol ChatsViewProtocol: AnyObject {
    var presenter: ChatsPresenterProtocol? { get set }
    
    func showChats(_ chats: [ChatViewModel])
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    func updateUnreadCount(for chatId: String, count: Int)
}

protocol ChatsPresenterProtocol: AnyObject {
    var view: ChatsViewProtocol? { get set }
    var interactor: ChatsInteractorInputProtocol? { get set }
    var router: ChatsRouterProtocol? { get set }
    
    func viewDidLoad()
    func viewWillAppear()
    func didSelectChat(at index: Int)
    func didSearchChats(with query: String)
    func didSelectSegment(_ segment: ChatSegment)
    func didPullToRefresh()
    func didTapCompose()
    func didTapArchive(chatId: String)
    func didTapMarkUnread(chatId: String)
    func didTapDelete(chatId: String)
    func didApplyFilters(dateFrom: Date?, dateTo: Date?, filterOperator: Int)
}

protocol ChatsInteractorInputProtocol: AnyObject {
    var presenter: ChatsInteractorOutputProtocol? { get set }
    
    func fetchChats()
    func searchChats(with query: String)
    func fetchArchivedChats()
    func markChatAsRead(chatId: String)
    func archiveChat(chatId: String)
    func markChatAsUnread(chatId: String)
    func deleteChat(chatId: String)
}

protocol ChatsInteractorOutputProtocol: AnyObject {
    func didFetchChats(_ chats: [ChatEntity])
    func didFailFetchingChats(with error: Error)
    func didSearchChats(_ chats: [ChatEntity])
    func didMarkChatAsRead(chatId: String)
    func didArchiveChat(chatId: String)
    func didMarkChatAsUnread(chatId: String)
    func didDeleteChat(chatId: String)
}

protocol ChatsRouterProtocol: AnyObject {
    var viewController: UIViewController? { get set }
    
    static func createModule() -> UIViewController
    func navigateToChat(with chatId: String, userName: String)
    func navigateToNewMessage()
}

enum ChatSegment: Int {
    case messages = 0
    case archive = 1
}

struct ChatViewModel {
    let id: String
    let userName: String
    let avatarURL: String?
    let lastMessage: String
    let timeAgo: String
    let unreadCount: Int
    let isVerified: Bool
    let isOnline: Bool
    let messageType: ChatMessageType
}
//
//  ChatsPresenter.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

final class ChatsPresenter: ChatsPresenterProtocol {
    
    weak var view: ChatsViewProtocol?
    var interactor: ChatsInteractorInputProtocol?
    var router: ChatsRouterProtocol?
    
    private var currentChats: [ChatEntity] = []
    private var currentSegment: ChatSegment = .messages
        
    func viewDidLoad() {
        view?.showLoading()
        interactor?.fetchChats()
    }
    
    func viewWillAppear() {
        interactor?.fetchChats()
    }
    
    func didSelectChat(at index: Int) {
        guard index < currentChats.count else { return }
        
        let chat = currentChats[index]
        let chatIdString = "\(chat.id)"
        
        if chat.unreadCount > 0 {
            interactor?.markChatAsRead(chatId: chatIdString)
        }
        
        router?.navigateToChat(with: chatIdString, userName: chat.recipientName, avatarURL: chat.recipientAvatarURL)
    }
    
    func didSearchChats(with query: String) {
        interactor?.searchChats(with: query)
    }
    
    func didSelectSegment(_ segment: ChatSegment) {
        currentSegment = segment
        view?.showLoading()
        
        switch segment {
        case .messages:
            interactor?.fetchChats()
        case .archive:
            interactor?.fetchArchivedChats()
        }
    }
    
    func didPullToRefresh() {
        switch currentSegment {
        case .messages:
            interactor?.fetchChats()
        case .archive:
            interactor?.fetchArchivedChats()
        }
    }
    
    func didTapCompose() {
        router?.navigateToNewMessage()
    }
    
    func didTapArchive(chatId: String) {
        interactor?.archiveChat(chatId: chatId)
    }
    
    func didTapMarkUnread(chatId: String) {
        interactor?.markChatAsUnread(chatId: chatId)
    }
    
    func didTapDelete(chatId: String) {
        interactor?.deleteChat(chatId: chatId)
    }
    
    func didApplyFilters(dateFrom: Date?, dateTo: Date?, filterOperator: Int) {
        var filteredChats = currentChats
        
        if let from = dateFrom {
            filteredChats = filteredChats.filter { $0.updatedAt >= from }
        }
        
        if let to = dateTo {
            filteredChats = filteredChats.filter { $0.updatedAt <= to }
        }
        
        let viewModels = mapToViewModels(filteredChats)
        view?.showChats(viewModels)
    }
        
    private func mapToViewModels(_ entities: [ChatEntity]) -> [ChatViewModel] {
        return entities.map { entity in
            ChatViewModel(
                id: "\(entity.id)",
                userName: entity.recipientName,
                avatarURL: entity.recipientAvatarURL,
                lastMessage: formatLastMessage(entity.lastMessage),
                timeAgo: formatTimeAgo(entity.updatedAt),
                unreadCount: entity.unreadCount,
                isVerified: entity.isVerified,
                isOnline: entity.isOnline,
                messageType: entity.lastMessage?.type ?? .text
            )
        }
    }
    
    private func formatLastMessage(_ message: ChatMessage?) -> String {
        guard let message = message else { return "" }
        
        if message.type != .text {
            return message.type.displayPrefix
        }
        
        return message.content
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "только что"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) мин."
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) ч."
        } else {
            let days = Int(interval / 86400)
            return "\(days) д."
        }
    }
}

extension ChatsPresenter: ChatsInteractorOutputProtocol {
    
    func didFetchChats(_ chats: [ChatEntity]) {
        currentChats = chats
        let viewModels = mapToViewModels(chats)
        
        view?.hideLoading()
        view?.showChats(viewModels)
    }
    
    func didFailFetchingChats(with error: Error) {
        view?.hideLoading()
        view?.showError(error.localizedDescription)
    }
    
    func didSearchChats(_ chats: [ChatEntity]) {
        let viewModels = mapToViewModels(chats)
        view?.showChats(viewModels)
    }
    
    func didMarkChatAsRead(chatId: String) {
        view?.updateUnreadCount(for: chatId, count: 0)
    }
    
    func didArchiveChat(chatId: String) {
        if let intId = Int(chatId) {
            currentChats.removeAll { $0.id == intId }
        }
        let viewModels = mapToViewModels(currentChats)
        view?.showChats(viewModels)
    }
    
    func didMarkChatAsUnread(chatId: String) {
        interactor?.fetchChats()
    }
    
    func didDeleteChat(chatId: String) {
        if let intId = Int(chatId) {
            currentChats.removeAll { $0.id == intId }
        }
        let viewModels = mapToViewModels(currentChats)
        view?.showChats(viewModels)
    }
}

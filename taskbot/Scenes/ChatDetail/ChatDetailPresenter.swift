//
//  ChatDetailPresenter.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatDetailPresenter: ChatDetailPresenterProtocol {
    weak var view: ChatDetailViewProtocol?
    var interactor: ChatDetailInteractorInputProtocol?
    var router: ChatDetailRouterProtocol?
    
    private var chatId: String = ""
    private var userName: String = ""
    private var userAvatarURL: String?
    private var messages: [MessageEntity] = []
    
    init(chatId: String, userName: String, avatarURL: String?) {
        self.chatId = chatId
        self.userName = userName
        self.userAvatarURL = avatarURL
    }
    
    func viewDidLoad() {
        view?.showUserInfo(name: userName, status: "В сети 1 ч. назад", avatarURL: userAvatarURL)
        view?.showLoading()
        interactor?.fetchMessages(chatId: chatId)
    }
    
    func didTapBack() {
        router?.navigateBack()
    }
    
    func didTapUserProfile() {
        router?.navigateToUserProfile(userId: chatId)
    }
    
    func didSendMessage(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        interactor?.sendMessage(chatId: chatId, text: text)
    }
    
    func didSendPhoto(image: UIImage) {
        interactor?.sendPhoto(chatId: chatId, image: image)
    }
    
    func didSendLocation(latitude: Double, longitude: Double) {
        interactor?.sendLocation(chatId: chatId, latitude: latitude, longitude: longitude)
    }
    
    func didScrollToTop() {
        guard let firstMessage = messages.first else { return }
        interactor?.loadMoreMessages(chatId: chatId, beforeId: firstMessage.id)
    }
    
    private func mapToViewModels(_ entities: [MessageEntity]) -> [MessageViewModel] {
        var viewModels: [MessageViewModel] = []
        var lastDate: String?
        
        for (index, entity) in entities.enumerated() {
            let dateString = formatDate(entity.createdAt)
            let showDateHeader = dateString != lastDate
            lastDate = dateString
            let showAvatar: Bool
            if entity.isOutgoing {
                showAvatar = false
            } else if index == 0 {
                showAvatar = true
            } else {
                let previousEntity = entities[index - 1]
                showAvatar = previousEntity.isOutgoing || previousEntity.senderId != entity.senderId
            }
            
            let viewModel = MessageViewModel(
                id: entity.id,
                isOutgoing: entity.isOutgoing,
                type: entity.type,
                text: entity.content.isEmpty ? nil : entity.content,
                mediaURL: entity.mediaURL,
                thumbnailURL: entity.thumbnailURL,
                time: formatTime(entity.createdAt),
                date: dateString,
                showDateHeader: showDateHeader,
                repostInfo: entity.repostInfo,
                avatarURL: entity.isOutgoing ? nil : userAvatarURL,
                showAvatar: showAvatar
            )
            
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, HH:mm"
        return formatter.string(from: date)
    }
}
extension ChatDetailPresenter: ChatDetailInteractorOutputProtocol {
    
    func didFetchMessages(_ messages: [MessageEntity]) {
        self.messages = messages
        let viewModels = mapToViewModels(messages)
        
        view?.hideLoading()
        view?.showMessages(viewModels)
        view?.scrollToBottom(animated: false)
    }
    
    func didSendMessage(_ message: MessageEntity) {
        messages.append(message)
        let viewModels = mapToViewModels(messages)
        
        view?.showMessages(viewModels)
        view?.scrollToBottom(animated: true)
    }
    
    func didFailSendingMessage(with error: Error) {
        view?.showError(error.localizedDescription)
    }
    
    func didLoadMoreMessages(_ messages: [MessageEntity]) {
        self.messages.insert(contentsOf: messages, at: 0)
        let viewModels = mapToViewModels(self.messages)
        view?.showMessages(viewModels)
    }
}
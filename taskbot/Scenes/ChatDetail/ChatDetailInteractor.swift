//
//  ChatDetailInteractor.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class ChatDetailInteractor: ChatDetailInteractorInputProtocol {
    weak var presenter: ChatDetailInteractorOutputProtocol?
    
    private let worker: ChatsWorkerProtocol
    private var chatId: String = ""
    
    init(worker: ChatsWorkerProtocol = ChatsWorker()) {
        self.worker = worker
    }
    
    func fetchMessages(chatId: String) {
        self.chatId = chatId
        
        guard let intChatId = Int(chatId) else {
            presenter?.didFetchMessages([])
            return
        }
        
        Task {
            do {
                let apiMessages = try await worker.fetchMessages(chatId: intChatId)
                let entities = apiMessages.map { mapToEntity($0) }
                
                await MainActor.run {
                    presenter?.didFetchMessages(entities)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFetchMessages([])
                }
            }
        }
    }
    
    func sendMessage(chatId: String, text: String) {
        guard let recipientId = Int(chatId) else { return }
        
        Task {
            do {
                let response = try await worker.sendMessage(recipientId: recipientId, content: text)
                
                let message = MessageEntity(
                    id: "\(response.messageId)",
                    senderId: "me",
                    isOutgoing: true,
                    type: .text,
                    content: text,
                    mediaURL: nil,
                    thumbnailURL: nil,
                    createdAt: Date(),
                    isRead: false,
                    repostInfo: nil
                )
                
                await MainActor.run {
                    presenter?.didSendMessage(message)
                }
            } catch {
                await MainActor.run {
                    presenter?.didFailSendingMessage(with: error)
                }
            }
        }
    }
    
    func sendPhoto(chatId: String, image: UIImage) {
        let message = MessageEntity(
            id: UUID().uuidString,
            senderId: "me",
            isOutgoing: true,
            type: .photo,
            content: "",
            mediaURL: nil,
            thumbnailURL: nil,
            createdAt: Date(),
            isRead: false,
            repostInfo: nil
        )
        presenter?.didSendMessage(message)
    }
    
    func sendLocation(chatId: String, latitude: Double, longitude: Double) {
        let message = MessageEntity(
            id: UUID().uuidString,
            senderId: "me",
            isOutgoing: true,
            type: .location,
            content: "\(latitude),\(longitude)",
            mediaURL: nil,
            thumbnailURL: nil,
            createdAt: Date(),
            isRead: false,
            repostInfo: nil
        )
        presenter?.didSendMessage(message)
    }
    
    func loadMoreMessages(chatId: String, beforeId: String) {
    }
    
    private func mapToEntity(_ api: MessageAPIModel) -> MessageEntity {
        let dateFormatter = ISO8601DateFormatter()
        
        return MessageEntity(
            id: "\(api.id)",
            senderId: api.senderId != nil ? "\(api.senderId!)" : "",
            isOutgoing: false,
            type: .text,
            content: api.content ?? "",
            mediaURL: nil,
            thumbnailURL: nil,
            createdAt: dateFormatter.date(from: api.createdAt ?? "") ?? Date(),
            isRead: api.isRead ?? false,
            repostInfo: nil
        )
    }
}
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
        
        Task {
            do {
                let apiMessages = try await worker.fetchMessages(chatId: chatId)
                let entities = apiMessages.map { mapToEntity($0) }
                
                await MainActor.run {
                    presenter?.didFetchMessages(entities)
                }
            } catch {
                let mockMessages = createMockMessages()
                await MainActor.run {
                    presenter?.didFetchMessages(mockMessages)
                }
            }
        }
    }
    
    func sendMessage(chatId: String, text: String) {
        Task {
            do {
                let apiMessage = try await worker.sendMessage(chatId: chatId, content: text, type: "text")
                let entity = mapToEntity(apiMessage)
                
                await MainActor.run {
                    presenter?.didSendMessage(entity)
                }
            } catch {
                let message = MessageEntity(
                    id: UUID().uuidString,
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
        Task {
            do {
                let content = "\(latitude),\(longitude)"
                let apiMessage = try await worker.sendMessage(chatId: chatId, content: content, type: "location")
                let entity = mapToEntity(apiMessage)
                
                await MainActor.run {
                    presenter?.didSendMessage(entity)
                }
            } catch {
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
                
                await MainActor.run {
                    presenter?.didSendMessage(message)
                }
            }
        }
    }
    
    func loadMoreMessages(chatId: String, beforeId: String) {
    }
    
    private func mapToEntity(_ api: MessageAPIModel) -> MessageEntity {
        let dateFormatter = ISO8601DateFormatter()
        
        return MessageEntity(
            id: api.id,
            senderId: api.senderId ?? "",
            isOutgoing: api.senderId == "me",
            type: mapMessageType(api.type),
            content: api.content ?? "",
            mediaURL: api.mediaUrl,
            thumbnailURL: nil,
            createdAt: dateFormatter.date(from: api.createdAt ?? "") ?? Date(),
            isRead: api.isRead ?? false,
            repostInfo: nil
        )
    }
    
    private func mapMessageType(_ type: String?) -> MessageType {
        switch type {
        case "photo": return .photo
        case "video": return .video
        case "voice": return .voice
        case "location": return .location
        case "repost": return .repost
        default: return .text
        }
    }
    
    private func createMockMessages() -> [MessageEntity] {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        
        return [
            MessageEntity(
                id: "1",
                senderId: "user1",
                isOutgoing: false,
                type: .text,
                content: "Привет",
                mediaURL: nil,
                thumbnailURL: nil,
                createdAt: yesterday,
                isRead: true,
                repostInfo: nil
            ),
            MessageEntity(
                id: "2",
                senderId: "user1",
                isOutgoing: false,
                type: .text,
                content: "Как дела? Как съездила в отпуск?",
                mediaURL: nil,
                thumbnailURL: nil,
                createdAt: yesterday,
                isRead: true,
                repostInfo: nil
            ),
            MessageEntity(
                id: "3",
                senderId: "me",
                isOutgoing: true,
                type: .text,
                content: "Привет! Съездила хорошо, видела китов и плавала на яхте",
                mediaURL: nil,
                thumbnailURL: nil,
                createdAt: yesterday,
                isRead: true,
                repostInfo: nil
            ),
            MessageEntity(
                id: "4",
                senderId: "me",
                isOutgoing: true,
                type: .repost,
                content: "",
                mediaURL: nil,
                thumbnailURL: nil,
                createdAt: yesterday,
                isRead: true,
                repostInfo: RepostInfo(
                    userName: "privetcvetochek...",
                    mediaURL: "",
                    isVideo: true
                )
            )
        ]
    }
}
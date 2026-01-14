//
//  ChatWebSocketManager.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

protocol ChatWebSocketDelegate: AnyObject {
    func chatWebSocketDidConnect()
    func chatWebSocketDidReceiveMessage(_ message: ChatMessageEvent)
    func chatWebSocketDidDisconnect()
    func chatWebSocketDidFail(with error: Error)
}

struct ChatMessageEvent: Codable {
    let type: String?
    let chatId: String?
    let message: MessageAPIModel?
    let senderId: String?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case chatId = "chat_id"
        case message
        case senderId = "sender_id"
        case content
    }
}

final class ChatWebSocketManager: NSObject {
    
    static let shared = ChatWebSocketManager()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    
    weak var delegate: ChatWebSocketDelegate?
    
    private let baseWSURL = "wss://interesnoitochka.ru/api/v1/ws"
    
    private override init() {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    func connectToAllChats() {
        guard let token = KeychainService.shared.accessToken else {
            print("❌ No access token for chat WebSocket")
            return
        }
        
        disconnect()
        
        // Get subscription token first, then connect
        Task {
            do {
                let subscriptionInfo: ChatSubscriptionResponse = try await APIClient.shared.request(
                    endpoint: "/chats/subscribe/all",
                    method: .get,
                    requiresAuth: true,
                    responseType: ChatSubscriptionResponse.self
                )
                
                await MainActor.run {
                    self.connectWithToken(subscriptionInfo.token ?? token)
                }
            } catch {
                print("❌ Failed to get chat subscription: \(error)")
                // Try connecting with access token directly
                await MainActor.run {
                    self.connectWithToken(token)
                }
            }
        }
    }
    
    private func connectWithToken(_ token: String) {
        // Try wss with /ws/ws/ pattern like auth WebSocket
        guard let url = URL(string: "wss://interesnoitochka.ru/api/v1/ws/ws/chats?token=\(token)") else {
            delegate?.chatWebSocketDidFail(with: WebSocketError.invalidURL)
            return
        }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("🔌 Connecting to chat WebSocket: \(url.absoluteString.prefix(80))...")
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage()
                
            case .failure(let error):
                print("❌ Chat WebSocket error: \(error)")
                self?.delegate?.chatWebSocketDidFail(with: error)
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        var text: String?
        
        switch message {
        case .string(let str):
            text = str
        case .data(let data):
            text = String(data: data, encoding: .utf8)
        @unknown default:
            break
        }
        
        guard let text = text, let data = text.data(using: .utf8) else { return }
        
        print("📨 Chat WebSocket received: \(text)")
        
        do {
            let event = try JSONDecoder().decode(ChatMessageEvent.self, from: data)
            delegate?.chatWebSocketDidReceiveMessage(event)
        } catch {
            print("⚠️ Failed to parse chat message: \(error)")
        }
    }
    
    func sendPing() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("❌ Ping failed: \(error)")
            }
        }
    }
}

extension ChatWebSocketManager: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ Chat WebSocket connected")
        delegate?.chatWebSocketDidConnect()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("🔌 Chat WebSocket disconnected")
        delegate?.chatWebSocketDidDisconnect()
    }
}

struct ChatSubscriptionResponse: Codable {
    let token: String?
    let url: String?
}

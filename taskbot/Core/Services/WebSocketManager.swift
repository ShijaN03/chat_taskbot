//
//  WebSocketManager.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import Foundation

protocol WebSocketManagerDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidReceiveTokens(_ tokens: TokenResponse)
    func webSocketDidFail(with error: Error)
    func webSocketDidDisconnect()
}

final class WebSocketManager: NSObject {
    
    static let shared = WebSocketManager()
    
    private let wsPaths = [
        "wss://interesnoitochka.ru/api/v1/ws/ws/session",
        "ws://interesnoitochka.ru/api/v1/ws/ws/session"
    ]
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    
    weak var delegate: WebSocketManagerDelegate?
    
    private var currentSessionId: String?
    private var currentEndpointIndex = 0
    private var endpoints: [URL] = []
    
    private override init() {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    func connect(sessionId: String) {
        currentSessionId = sessionId
        prepareEndpoints(for: sessionId)
        currentEndpointIndex = 0
        connectCurrentEndpoint()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func prepareEndpoints(for sessionId: String) {
        endpoints = wsPaths.compactMap { URL(string: "\($0)/\(sessionId)") }
    }
    
    private func connectCurrentEndpoint() {
        guard currentEndpointIndex < endpoints.count else {
            delegate?.webSocketDidFail(with: WebSocketError.connectionFailed)
            return
        }
        
        disconnect()
        
        let url = endpoints[currentEndpointIndex]
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    private func tryNextEndpoint(after error: Error) {
        currentEndpointIndex += 1
        if currentEndpointIndex < endpoints.count {
            connectCurrentEndpoint()
        } else {
            delegate?.webSocketDidFail(with: error)
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage()
                
            case .failure(let error):
                self?.tryNextEndpoint(after: error)
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            parseTokenMessage(text)
            
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                parseTokenMessage(text)
            }
            
        @unknown default:
            break
        }
    }
    
    private func parseTokenMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            delegate?.webSocketDidReceiveTokens(tokenResponse)
            disconnect()
        } catch {
            print("WebSocket received non-token message: \(text)")
        }
    }
}
extension WebSocketManager: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        delegate?.webSocketDidConnect()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        delegate?.webSocketDidDisconnect()
    }
}
enum WebSocketError: Error, LocalizedError {
    case invalidURL
    case connectionFailed
    case messageParsingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .connectionFailed:
            return "Failed to connect to WebSocket"
        case .messageParsingFailed:
            return "Failed to parse WebSocket message"
        }
    }
}
//
//  LoginViewController.swift
//  taskbot
//
//  Created by shijan on 14.01.2026.
//

import UIKit

final class LoginViewController: UIViewController {
    
    private let authManager = AuthManager.shared
    private var isConnecting = false
    
    // Container for auth decorations
    private lazy var authContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bluestarView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_bluestar")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var flowerView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_flower")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var handView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_hand")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var messageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_message")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Вход в учетную запись"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Вход в приложение осуществляется\nчерез аккаунт в Telegram"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.3, green: 0.7, blue: 0.4, alpha: 1)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти в приложение", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 47/255, green: 127/255, blue: 255/255, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Зарегистрироваться", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.backgroundColor = UIColor(red: 84/255, green: 85/255, blue: 91/255, alpha: 1)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "При входе или регистрации вы соглашаетесь\nс нашей Политикой использования"
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authManager.stopWebSocketLogin()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 37/255, green: 40/255, blue: 45/255, alpha: 1)
        
        view.addSubview(authContainer)
        authContainer.addSubview(bluestarView)
        authContainer.addSubview(flowerView)
        authContainer.addSubview(handView)
        authContainer.addSubview(messageView)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(statusLabel)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        view.addSubview(termsLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Auth container
            authContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            authContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            authContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            authContainer.heightAnchor.constraint(equalToConstant: 260),
            
            // Blue star (centered, main element)
            bluestarView.centerXAnchor.constraint(equalTo: authContainer.centerXAnchor),
            bluestarView.centerYAnchor.constraint(equalTo: authContainer.centerYAnchor),
            bluestarView.widthAnchor.constraint(equalToConstant: 270),
            bluestarView.heightAnchor.constraint(equalToConstant: 270),
            
            // Flower (top left of bluestar)
            flowerView.trailingAnchor.constraint(equalTo: bluestarView.leadingAnchor, constant: 80),
            flowerView.topAnchor.constraint(equalTo: bluestarView.topAnchor, constant: 40),
            flowerView.widthAnchor.constraint(equalToConstant: 80),
            flowerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Hand (right side of bluestar)
            handView.leadingAnchor.constraint(equalTo: bluestarView.trailingAnchor, constant: -100),
            handView.topAnchor.constraint(equalTo: bluestarView.topAnchor, constant: 70),
            handView.widthAnchor.constraint(equalToConstant: 70),
            handView.heightAnchor.constraint(equalToConstant: 90),
            
            // Message (left bottom of bluestar)
            messageView.trailingAnchor.constraint(equalTo: bluestarView.leadingAnchor, constant: 50),
            messageView.bottomAnchor.constraint(equalTo: bluestarView.bottomAnchor, constant: -30),
            messageView.widthAnchor.constraint(equalToConstant: 90),
            messageView.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: authContainer.bottomAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            statusLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -12),
            
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.bottomAnchor.constraint(equalTo: termsLabel.topAnchor, constant: -20),
            
            termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            termsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            termsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30)
        ])
    }
    
    private func initializeSession() {
        if !authManager.hasSession {
            Task {
                do {
                    _ = try await authManager.getAnonymousSession()
                    print("Anonymous session created")
                } catch {
                    print("Failed to create session: \(error)")
                }
            }
        }
    }
    
    @objc private func loginTapped() {
        goToMainApp()
    }
    
    @objc private func registerTapped() {
        startTelegramLogin()
    }
    
    private func startTelegramLogin() {
        guard !isConnecting else { return }
        Task {
            do {
                if !authManager.hasSession {
                    _ = try await authManager.getAnonymousSession()
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.connectWebSocket()
                }
            } catch {
                showError("Не удалось создать сессию: \(error.localizedDescription)")
            }
        }
    }
    
    private func connectWebSocket() {
        isConnecting = true
        activityIndicator.startAnimating()
        statusLabel.text = "Ожидание подтверждения..."
        statusLabel.isHidden = false
        
        do {
            try authManager.startWebSocketLogin(delegate: self)
            if let qrURL = authManager.getQRCodeURL(),
               let url = URL(string: qrURL) {
                UIApplication.shared.open(url)
            }
        } catch {
            isConnecting = false
            activityIndicator.stopAnimating()
            statusLabel.isHidden = true
            showError("Ошибка подключения: \(error.localizedDescription)")
        }
    }
    
    private func goToMainApp() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let windowScene = view.window?.windowScene,
              let window = windowScene.windows.first else { return }
        
        let chatsVC = ChatsRouter.createModule()
        let navController = UINavigationController(rootViewController: chatsVC)
        navController.navigationBar.isHidden = true
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = navController
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
extension LoginViewController: WebSocketManagerDelegate {
    
    func webSocketDidConnect() {
        print("WebSocket connected, waiting for tokens...")
    }
    
    func webSocketDidReceiveTokens(_ tokens: TokenResponse) {
        authManager.saveTokens(tokens)
        
        DispatchQueue.main.async { [weak self] in
            self?.isConnecting = false
            self?.activityIndicator.stopAnimating()
            self?.statusLabel.text = "Успешный вход!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.goToMainApp()
            }
        }
    }
    
    func webSocketDidFail(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnecting = false
            self?.activityIndicator.stopAnimating()
            self?.statusLabel.isHidden = true
            self?.showError("Ошибка соединения: \(error.localizedDescription)")
        }
    }
    
    func webSocketDidDisconnect() {
        print("WebSocket disconnected")
    }
}

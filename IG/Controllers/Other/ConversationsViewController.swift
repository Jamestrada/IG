//
//  ConversationsViewController.swift
//  IG
//
//  Created by James Estrada on 7/29/21.
//

import UIKit
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let targetUser: User
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let message: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Conversations"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListeningForConversations()
        })
                                                                                                                          
    }
    
    private func startListeningForConversations() {
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        DatabaseManager.shared.getAllConversations(for: username) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapCompose() {
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController(user: model.targetUser, id: model.id)
        vc.title = model.targetUser.username
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            // update model
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) { [weak self] success in
                if success {
                    self?.conversations.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
            
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

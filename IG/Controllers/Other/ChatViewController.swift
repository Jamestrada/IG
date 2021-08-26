//
//  ChatViewController.swift
//  IG
//
//  Created by James Estrada on 8/2/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var senderId: String
    public var displayName: String
    public var photoURL: String
}

class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    
    private let conversationId: String?
    
    private let user: User
    
    private var messages = [Message]()
        
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(senderId: email, displayName: "James Estrada", photoURL: "")
    }
    
    // MARK: - Init
    
    init(user: User, id: String?) {
        self.user = user
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        
        if let conversationId = conversationId {
            listenForMessages(id: conversationId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("What's up from IG")))
//        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("What's up from IG. What's up from IG. What's up from IG. What's up from IG")))
        view.backgroundColor = .systemBackground
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMessageId() else {
            return
        }
        print("Sending: \(text)")
        // Send message
        if isNewConversation {
            // Create conversation in database
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: user, name: user.username , firstMessage: message) { [weak self] success in
                if success {
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            }
        }
        else {
            // Append to existing conversation data
        }
    }
    
    private func createMessageId() -> String? {
        // targetEmail, senderEmail, date
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            return nil
        }
        let dateString = DateFormatter.formatter.string(from: Date())
        let newId = "\(user.email)_\(currentUserEmail)_\(dateString)"
        print("created message id: \(newId)")
        
        return newId
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType { // The framework shows the chat bubble on the right for sender and left for receiver
        if let sender = selfSender {
            return sender
        }
        fatalError("selfSender is nil, email should be cached")
        return Sender(senderId: "777", displayName: "", photoURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit

class ConversationViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var theme: Theme = ThemeDataStore.shared.theme
    
    public var chat: ChannelModel!
    
    private var messagesData: [MessageModel] = []
    
    // MARK: Life cycle
    
    private var isKeyboardShowing = false
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var customInputView: UIView!
    var sendButton: UIButton!
    var addMediaButtom: UIButton!
    let textField = FlexibleTextView()
    
    override var inputAccessoryView: UIView? {
        
        if customInputView == nil {
            customInputView = CustomView()
            customInputView.backgroundColor = theme.mainColors.chat.myMessageBackground
            
            textField.textColor = theme.mainColors.chat.text
            textField.backgroundColor = theme.mainColors.chat.myMessageBackground
            textField.placeholder = "Сообщение"
            textField.font = .systemFont(ofSize: 15)
            textField.layer.cornerRadius = 5
            
            customInputView.autoresizingMask = .flexibleHeight
            
            customInputView.addSubview(textField)
            
            sendButton = UIButton(type: .system)
            sendButton.isEnabled = true
            sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            sendButton.setTitle("Send", for: .normal)
            sendButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            sendButton.addTarget(self, action: #selector(sendMessageButtonTapped(_:)), for: .touchUpInside)
            customInputView?.addSubview(sendButton)
            
            addMediaButtom = UIButton(type: .custom)
            addMediaButtom.setImage(UIImage(imageLiteralResourceName: "icon_send").withRenderingMode(.alwaysTemplate), for: .normal)
            addMediaButtom.isEnabled = true
            
            addMediaButtom.contentEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 5, right: 0)
            addMediaButtom.addTarget(self, action: #selector(sendMessageButtonTapped(_:)), for: .touchUpInside)
            customInputView?.addSubview(addMediaButtom)
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            addMediaButtom.translatesAutoresizingMaskIntoConstraints = false
            sendButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            
            addMediaButtom.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            addMediaButtom.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            
            textField.maxHeight = 80
            
            addMediaButtom.leadingAnchor.constraint(
                equalTo: customInputView.leadingAnchor,
                constant: 8
            ).isActive = true
            
            addMediaButtom.trailingAnchor.constraint(
                equalTo: textField.leadingAnchor,
                constant: -8
            ).isActive = true
            
            addMediaButtom.bottomAnchor.constraint(
                equalTo: customInputView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true
            
            textField.trailingAnchor.constraint(
                equalTo: sendButton.leadingAnchor,
                constant: 0
            ).isActive = true
            
            textField.topAnchor.constraint(
                equalTo: customInputView.topAnchor,
                constant: 8
            ).isActive = true
            
            textField.bottomAnchor.constraint(
                equalTo: customInputView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true
            
            sendButton.leadingAnchor.constraint(
                equalTo: textField.trailingAnchor,
                constant: 0
            ).isActive = true
            
            sendButton.trailingAnchor.constraint(
                equalTo: customInputView.trailingAnchor,
                constant: -8
            ).isActive = true
            
            sendButton.bottomAnchor.constraint(
                equalTo: customInputView.layoutMarginsGuide.bottomAnchor,
                constant: -8
            ).isActive = true
        }
        
        customInputView.backgroundColor = theme.mainColors.primaryBackground
        
        return customInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        navigationController?.navigationBar.backgroundColor = theme.mainColors.navigationBar.background
        
        self.view.backgroundColor = theme.mainColors.primaryBackground
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        fetchData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UI Setup
    
    private func setupTableView() {
        tableView.backgroundColor = theme.mainColors.primaryBackground
        self.tableView.register(UINib(nibName: String(describing: MyMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: "MyMesTableViewIndentifier")
        self.tableView.register(UINib(nibName: String(describing: NotMyMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: "NotMyMesTableViewIndentifier")
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    // MARK: Private API
    
    @objc func handleTap() {
        textField.resignFirstResponder()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    @objc func sendMessageButtonTapped(_ sender: Any) {
        if let message = textField.text, !message.trimmingCharacters(in: .whitespaces).isEmpty {
            FireStoreManager.shared.createMessage(identifier: chat.identifier, newMessage: message)
            textField.text = ""
        }
    }
    
    func fetchData() {
        FireStoreManager.shared.updateMessages(identifier: chat.identifier) { [weak self] data in
            
            self?.messagesData = data
            DispatchQueue.main.async {
                self?.tableView.reloadData()   
                // self?.tableView.scrollsToBottom(animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate
// MARK: - UITableViewDataSource
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messagesData[indexPath.row].senderId == FireStoreManager.shared.senderId {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMesTableViewIndentifier") as? MyMessageTableViewCell else {
                fatalError("DequeueReusableCell failed while casting")
            }
            
            cell.configure( messagesData[indexPath.row].content)
            cell.configureTheme(theme: theme)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotMyMesTableViewIndentifier") as? NotMyMessageTableViewCell else {
                fatalError("DequeueReusableCell failed while casting")
            }
            
            cell.configure( messagesData[indexPath.row])
            cell.configureTheme(theme: theme)
            cell.selectionStyle = .none
            return cell
        }
    }
}

class CustomView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}

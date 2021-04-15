//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit
import CoreData

class ConversationViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    var fireStoreService: FireStoreServiceProtocol?
    var coreDataService: CoreDataServiceProtocol?
    
    var theme: Theme?
    
    public var chat: ChannelModel!
    
    // MARK: Life cycle
    
    private var isKeyboardShowing = false
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var customInputView: UIView!
    var sendButton: UIButton!
    var addMediaButtom: UIButton!
    let textField = FlexibleTextView()
    
    // следит за изменениями данных в контексте,
    // позволяет работать с результатом исполнения NSFetchRequest
    // кеширует результаты запросов
    lazy var fetchedResultsController: NSFetchedResultsController<Message_db> = {
        let request = NSFetchRequest<Message_db>(entityName: "Message_db")
        
        let descriptor1 = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [descriptor1]
        
        request.predicate = NSPredicate(format: "channel.identifier == %@", chat.identifier)
        
        request.resultType = .managedObjectResultType
        request.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataService!.mainContext,
            sectionNameKeyPath: nil, cacheName: "messages.\(chat.identifier)")
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override var inputAccessoryView: UIView? {
        
        if customInputView == nil {
            customInputView = CustomView()
            if let theme = theme {
                customInputView.backgroundColor = theme.mainColors.chat.myMessageBackground
                
                textField.textColor = theme.mainColors.chat.text
                textField.backgroundColor = theme.mainColors.chat.myMessageBackground
            }
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
        
        if let theme = theme {
            customInputView.backgroundColor = theme.mainColors.primaryBackground
        }
        
        return customInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        if let theme = theme {
            navigationController?.navigationBar.backgroundColor = theme.mainColors.navigationBar.background
            
            self.view.backgroundColor = theme.mainColors.primaryBackground
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        updateMessages()
        performFetch()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        fetchedResultsController.delegate = nil
        
    }
    
    // MARK: UI Setup
    
    private func setupTableView() {
        if let theme = theme {
            tableView.backgroundColor = theme.mainColors.primaryBackground
        }
        
        self.tableView.register(UINib(nibName: String(describing: MyMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: "MyMesTableViewIndentifier")
        self.tableView.register(UINib(nibName: String(describing: NotMyMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: "NotMyMesTableViewIndentifier")
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    // MARK: Private API
    
    private func performFetch() {
        do {
            try
                fetchedResultsController.performFetch()
        } catch {
            fatalError()
        }
    }
    
    private func updateMessages() {
        fireStoreService?.updateMessages(identifier: chat.identifier ,
                                         channel: ChannelModel(identifier: chat.identifier ,
                                                               name: chat.name ,
                                                               lastMessage: chat.lastMessage,
                                                               lastActivity: chat.lastActivity))
    }
    
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
            DispatchQueue.global(qos: .default).async {
                self.fireStoreService?.createMessage(identifier: self.chat.identifier, newMessage: message)
            }
            textField.text = ""
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
        guard let sections = self.fetchedResultsController.sections
        else {
            return 0
        }
        
        let sectionInfo = sections[section]
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.fetchedResultsController.object(at: indexPath)
        
        if message.senderId == fireStoreService?.senderId {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMesTableViewIndentifier") as? MyMessageTableViewCell else {
                fatalError("DequeueReusableCell failed while casting")
            }
            
            cell.configure( message.content)
            if let theme = theme {
                cell.configureTheme(theme: theme)
            }
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotMyMesTableViewIndentifier") as? NotMyMessageTableViewCell else {
                fatalError("DequeueReusableCell failed while casting")
            }
            cell.configure( message)
            if let theme = theme {
                cell.configureTheme(theme: theme)
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ConversationViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            Logger.log("inserted")
            guard let newIndexPath = newIndexPath else { return }
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            Logger.log("moved")
            guard let newIndexPath = newIndexPath, let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            Logger.log("update")
            guard let indexPath = indexPath else { return }
            guard let message = controller.object(at: indexPath) as? Message_db else { return }
            
            if message.senderId == fireStoreService?.senderId {
                
                guard let cell = tableView.cellForRow(at: indexPath) as? MyMessageTableViewCell else {
                    return
                }
                
                cell.configure(message.content)
            } else {
                guard let cell = tableView.cellForRow(at: indexPath) as? NotMyMessageTableViewCell else {
                    return
                }
                
                cell.configure(message)
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            Logger.log("delete")
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            Logger.log("must not be called")
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

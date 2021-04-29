//
//  ConversationListViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit
import CoreData
class ConversationListViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    var themeDataStore: ThemeDataStore?
    var theme: Theme?
    let simpleOver = SimpleSlideTransition()
    private var profileImage: UIImage?
    
    var userDataStore: UserDataStoreProtocol?
    var coreDataService: CoreDataServiceProtocol?
    var fireStoreService: FireStoreServiceProtocol?
    
    var presentationAssembly: PresenentationAssemblyProtocol?
    
    // следит за изменениями данных в контексте,
    // позволяет работать с результатом исполнения NSFetchRequest
    // кеширует результаты запросов
    lazy var fetchedResultsController: NSFetchedResultsController<Channel_db> = {
        let request = NSFetchRequest<Channel_db>(entityName: "Channel_db")
        
        let descriptor1 = NSSortDescriptor(key: "lastActivity", ascending: false)
        let descriptor2 = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [descriptor1, descriptor2]
        
        request.resultType = .managedObjectResultType
        request.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataService!.mainContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet weak private var tableView: UITableView!
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadProfile()
        
        setupImageRightNavButton(UIImage(named: "avatar2")?.withRenderingMode(.alwaysOriginal))
        setupTheme()
        
        updateChannels()
        performFetch()
        navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: UI Setup
    
    private func setupTheme() {
        if let theme = themeDataStore?.theme {
            view.backgroundColor = theme.mainColors.primaryBackground
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: theme.mainColors.navigationBar.title]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: theme.mainColors.navigationBar.title]
                navBarAppearance.backgroundColor = theme.mainColors.navigationBar.background
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            } else {
                UINavigationBar.appearance().isTranslucent = false
                self.navigationController?.navigationBar.barTintColor = theme.mainColors.navigationBar.tint
                UINavigationBar.appearance().barStyle = theme.mainColors.navigationBar.barStyle
                self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor:
                        theme.mainColors.navigationBar.title ]
                UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: theme.mainColors.navigationBar.title]
                UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: theme.mainColors.navigationBar.title]
            }
            
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
            
            setNeedsStatusBarAppearanceUpdate()
            
            tableView.separatorColor = theme.mainColors.chatList.text
            tableView.backgroundColor = theme.mainColors.primaryBackground
            tableView.reloadData()
        }
    }
    
    private func setupImageRightNavButton(_ image: UIImage?) {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(profileAvatarTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 32)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 32)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
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
    
    private func updateChannels() {
        fireStoreService?.updateChannels()
    }
    
    private func loadProfile() {
        userDataStore?.readProfile { [weak self] (profile) in
            DispatchQueue.main.async {
                self?.profileImage = self?.userDataStore?.profile?.avatar
                self?.setupImageRightNavButton(self?.profileImage)
            }
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        if let controller = presentationAssembly?.settingsViewController() {
            controller.delegate = self
            
            controller.closure = {  [weak self] theme in
                self?.theme = theme
                
                DispatchQueue.main.async {
                    self?.setupTheme()
                }
            }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func newChatBarButtonItemTapped(_ sender: Any) {
        let alert = UIAlertController(title: "New chat", message: "create a new chat room", preferredStyle: .alert)
        
        // 2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "input chat name"
        }
        
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields?.first 
            if let textFieldData = textField?.text, !textFieldData.trimmingCharacters(in: .whitespaces).isEmpty {
                DispatchQueue.global(qos: .default).async {
                    self.fireStoreService?.createChannel(name: textFieldData) { result in
                        if case Result.failure(_) = result {
                        }
                    }
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: { _ in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func profileAvatarTapped(_ sender: Any) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        if let controller = presentationAssembly?.profileViewController() {
            controller.userDataStore = userDataStore
            controller.presentationAssembly = presentationAssembly
            controller.existingImage = userDataStore?.profile?.avatar
            
            controller.onProfileChanged = { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.loadProfile()
                }
            }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}

// MARK: - UITableViewDelegate
// MARK: - UITableViewDataSource
extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "History"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        
        headerView.contentView.backgroundColor = themeDataStore?.theme.mainColors.chatList.cellBackground
        
        headerView.textLabel?.textColor = themeDataStore?.theme.mainColors.chatList.text
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections
        else {
            return 0
        }
        
        let sectionInfo = sections[section]
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = fetchedResultsController.object(at: indexPath)
        if let conversationVC = presentationAssembly?.conversationViewController(channelId: channel.identifier ?? "", channelName: channel.name ?? "") {
            conversationVC.chat = ChannelModel(identifier: channel.identifier ?? "",
                                               name: channel.name ?? "",
                                               lastMessage: channel.lastMessage,
                                               lastActivity: channel.lastActivity)
            
            navigationController?.pushViewController(conversationVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as? DialogTableViewCell else {
            fatalError("DequeueReusableCell failed while casting")
        }
        
        let channel = self.fetchedResultsController.object(at: indexPath)
        cell.configure(with: channel)
        
        if let theme = themeDataStore?.theme {
            cell.configureTheme(theme: theme)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {(_, indexPath: IndexPath) -> Void in
            let channel = self.fetchedResultsController.object(at: indexPath)
            
            self.fireStoreService?.deleteChannelMessages(identifier: channel.identifier ?? "")
            
            self.fireStoreService?.deleteChannel(identifier: channel.identifier ?? "")
            
            self.performFetch()
            
        }
        return [delete]
    }
    
}

// MARK: - ThemesPickerDelegate
extension ConversationListViewController: ThemesPickerDelegate {
    
    func themeDidChange(_ themeOption: Theme) {
        setupTheme()
        tableView.reloadData()
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ConversationListViewController: NSFetchedResultsControllerDelegate {
    
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
            guard let newIndexPath = newIndexPath else { return }
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath, let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            guard let cell = tableView.cellForRow(at: indexPath) as? DialogTableViewCell else {
                return
            }
            guard let channel = controller.object(at: indexPath) as? Channel_db else { return }
            cell.configure(with: channel)
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            Logger.log("must not be called")
        }
    }
    
}

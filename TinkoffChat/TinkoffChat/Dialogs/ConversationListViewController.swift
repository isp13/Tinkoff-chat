//
//  ConversationListViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit

class ConversationListViewController: UIViewController {
    
    private var theme: Theme = ThemeDataStore.shared.theme
    var userDataStore = UserDataStore.shared
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var channels: [ChannelModel] = []
    
    private var profileImage: UIImage?
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadProfile()
        
        setupImageRightNavButton(UIImage(named: "avatar2")?.withRenderingMode(.alwaysOriginal))
        
        setupTheme()
        
        FireStoreManager.shared.updateChannels { [weak self] data in
            
            self?.channels = data
            DispatchQueue.main.async {
            self?.tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: UI Setup
    
    private func setupTheme() {
        let theme = ThemeDataStore.shared.theme
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
    
    private func loadProfile() {
        userDataStore.readProfile { [weak self] (profile) in
            DispatchQueue.main.async {
                self?.profileImage = self?.userDataStore.profile?.avatar
                self?.setupImageRightNavButton(self?.profileImage)
            }
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "settings") as? ThemesViewController
        
        if let controller = viewController {
            controller.delegate = self
            //            controller.selectedTheme = theme
            
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
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if let textFieldData = textField?.text, !textFieldData.trimmingCharacters(in: .whitespaces).isEmpty {
                FireStoreManager.shared.createChannel(name: textFieldData) { result in
                    if case Result.failure(_) = result {
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
        self.performSegue(withIdentifier: "showProfileSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailDialog" {
            // do something you want
            guard let destinationVC = segue.destination as? ConversationViewController, let indexPath = sender as? IndexPath else { return }
            destinationVC.title = channels[indexPath.row].name
            destinationVC.chat = channels[indexPath.row]
        } else if segue.identifier == "showProfileSegue" {
            guard let destinationVC = segue.destination as? ProfileViewController  else {return }
            
            destinationVC.userDataStore = userDataStore
            destinationVC.existingImage = userDataStore.profile?.avatar
            
            destinationVC.onProfileChanged = { [weak self] (_) in
                DispatchQueue.main.async {
                    self?.loadProfile()
                }
            }
        }
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
        
        headerView.contentView.backgroundColor = ThemeDataStore.shared.theme.mainColors.chatList.cellBackground
        
        headerView.textLabel?.textColor = ThemeDataStore.shared.theme.mainColors.chatList.text
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as? DialogTableViewCell else {
            fatalError("DequeueReusableCell failed while casting")
        }
        
        cell.configure(with: channels[indexPath.row])
        
        cell.configureTheme(theme: ThemeDataStore.shared.theme)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailDialog", sender: indexPath)
    }
}

// MARK: - ThemesPickerDelegate
extension ConversationListViewController: ThemesPickerDelegate {
    
    func themeDidChange(_ themeOption: Theme) {
        setupTheme()
        tableView.reloadData()
    }
}

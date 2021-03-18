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
    
    private var onlinePeopleChats: [ConversationChatData] = []
    private var offlinePeopleChats: [ConversationChatData] = []
    
    private var profileImage: UIImage?
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        
        self.onlinePeopleChats = fakeData.filter{$0.online == true}
        self.offlinePeopleChats = fakeData.filter{$0.online == false}
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadProfile()
        
        setupImageRightNavButton(UIImage(named: "avatar2")?.withRenderingMode(.alwaysOriginal))
        
        setupTheme()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        button.addTarget(self, action:#selector(profileAvatarTapped), for: .touchUpInside)
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
    
    @objc private func profileAvatarTapped(_ sender: Any) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.performSegue(withIdentifier: "showProfileSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailDialog" {
            //do something you want
            guard let destinationVC = segue.destination as? ConversationViewController, let indexPath = sender as? IndexPath else { return }
            destinationVC.title = indexPath.section == 0 ?  onlinePeopleChats[indexPath.row].name : offlinePeopleChats[indexPath.row].name
        }
        else if segue.identifier == "showProfileSegue" {
            guard let destinationVC = segue.destination as? ProfileViewController  else {return }
            
            destinationVC.userDataStore = userDataStore
            destinationVC.existingImage = userDataStore.profile?.avatar
            
            destinationVC.onProfileChanged = { [weak self] (profile) in
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? onlinePeopleChats.count : offlinePeopleChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! DialogTableViewCell
        
        cell.configure(with: indexPath.section == 0 ?  onlinePeopleChats[indexPath.row] : offlinePeopleChats[indexPath.row])
        
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
        print("themeDidChange called")
        setupTheme()
        
        tableView.reloadData()
    }
}

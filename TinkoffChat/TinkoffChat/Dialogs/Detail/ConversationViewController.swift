//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit



class ConversationViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private var theme: Theme = ThemeManager.current
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messagesData = messagesData.sorted(by: {$0.date ?? Date() < $1.date ?? Date()})

        setupTableView()
        
        tableView.backgroundColor = theme.mainColors.primaryBackground
        navigationController?.navigationBar.backgroundColor = theme.mainColors.navigationBar.background

    }
    
    // MARK: UI Setup
    
    fileprivate func setupTableView() {
        self.tableView.register(UINib(nibName: String(describing: MyMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: "MyMesTableViewIndentifier")
        self.tableView.register(UINib(nibName: String(describing: NotMyMessageTableViewCell.self), bundle: nil), forCellReuseIdentifier: "NotMyMesTableViewIndentifier")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
     return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (messagesData[indexPath.row].isMy ?? false) {
            let cell = tableView.dequeueReusableCell(withIdentifier:   "MyMesTableViewIndentifier") as! MyMessageTableViewCell
            
            cell.configure( messagesData[indexPath.row].text)
            cell.configureTheme(theme: theme)
            cell.selectionStyle = .none
            return cell
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier:   "NotMyMesTableViewIndentifier") as! NotMyMessageTableViewCell
            
            cell.configure( messagesData[indexPath.row].text)
            cell.configureTheme(theme: theme)
            cell.selectionStyle = .none
            return cell
        }
    }
}

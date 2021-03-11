//
//  ConversationListViewController.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit


class ConversationListViewController: UIViewController, ControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var onlinePeopleChats: [ConversationChatData] = []
    var offlinePeopleChats: [ConversationChatData] = []
    
    var profileImage: UIImage?
    
    // MARK: Life cycle

    override func viewDidLoad() {
        
        self.onlinePeopleChats = fakeData.filter{$0.online == true}
        self.offlinePeopleChats = fakeData.filter{$0.online == false}
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let image = UIImage(named: "avatar2")?.withRenderingMode(.alwaysOriginal)
        
        setupImageRightNavButton(image)
        
    }
    
    
    // MARK: Private API
    
    @objc private func profileAvatarTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showProfileSegue", sender: sender)
    }
    
    private func setupImageRightNavButton(_ image: UIImage?) {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action:#selector(profileAvatarTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 32)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 32)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    
    func changeAvatarBarView(_ image: UIImage?) {
        setupImageRightNavButton(image)
        profileImage = image
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailDialog" {
            //do something you want
            guard let destinationVC = segue.destination as? ConversationViewController, let indexPath = sender as? IndexPath else { return }
            destinationVC.title = indexPath.section == 0 ?  onlinePeopleChats[indexPath.row].name : offlinePeopleChats[indexPath.row].name
        }
        else if segue.identifier == "showProfileSegue" {
            guard let destinationVC = segue.destination as? ProfileViewController  else {return }
            destinationVC.delegate = self
            destinationVC.existingImage = profileImage
        }
    }
}


// MARK: - UITableViewDelegate
// MARK: - UITableViewDataSource
extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "History"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? onlinePeopleChats.count : offlinePeopleChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! DialogTableViewCell
        
        cell.data = indexPath.section == 0 ?  onlinePeopleChats[indexPath.row] : offlinePeopleChats[indexPath.row]
        
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.74, alpha: 1.00)
        }
        else {
            cell.backgroundColor = .white
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailDialog", sender: indexPath)
    }
}

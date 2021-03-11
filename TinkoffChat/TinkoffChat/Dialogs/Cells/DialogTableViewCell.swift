//
//  DialogTableViewCell.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 01.03.2021.
//

import UIKit

class DialogTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var nameLabel: UILabel!
    
    @IBOutlet weak private var messageLabel: UILabel!
    
    @IBOutlet weak private var dataLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       
        
    }
    
    func configure(with model: ConversationChatData) {
        if let chatName = model.name {
            self.nameLabel.text = chatName
        }
        else {
            self.nameLabel.text = "No Name"
        }
        
        if let chatMessage = model.message {
            self.messageLabel.text = chatMessage
            
            if model.hasUnreadMessages {
                self.messageLabel.font =  UIFont.boldSystemFont(ofSize: 16.0)
            }
        }
        else {
            self.messageLabel.text = "Empty message"
        }
        
        if let chatDate = model.date {
            self.dataLabel.text = chatDate.chatDateRepresentation()
        }
        else {
            self.dataLabel.text = "--"
        }
    }
    
    func configureTheme(theme: Theme) {
        self.nameLabel.textColor = theme.mainColors.chatList.text
        self.messageLabel.textColor = theme.mainColors.chatList.text
        self.dataLabel.textColor = theme.mainColors.chatList.text
        
        self.backgroundColor = theme.mainColors.chatList.cellBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

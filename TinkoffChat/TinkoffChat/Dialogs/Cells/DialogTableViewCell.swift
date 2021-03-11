//
//  DialogTableViewCell.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 01.03.2021.
//

import UIKit

class DialogTableViewCell: UITableViewCell {
    
    var data: ConversationChatData!

    
    @IBOutlet weak private var nameLabel: UILabel!
    
    @IBOutlet weak private var messageLabel: UILabel!
    
    @IBOutlet weak private var dataLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let chatName = data.name {
            self.nameLabel.text = chatName
        }
        else {
            self.nameLabel.text = "No Name"
        }
        
        if let chatMessage = data.message {
            self.messageLabel.text = chatMessage
            
            if data.hasUnreadMessages {
                self.messageLabel.font =  UIFont.boldSystemFont(ofSize: 16.0)
            }
        }
        else {
            self.messageLabel.text = "Empty message"
        }
        
        if let chatDate = data.date {
            self.dataLabel.text = chatDate.chatDateRepresentation()
        }
        else {
            self.dataLabel.text = "--"
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

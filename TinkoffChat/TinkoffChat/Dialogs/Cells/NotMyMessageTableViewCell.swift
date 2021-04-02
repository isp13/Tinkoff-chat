//
//  NotMyMessageTableViewCell.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit

class NotMyMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var message: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(_ message: MessageModel) {
        messageLabel.text = message.content
        nameLabel.text = message.senderName
    }
    
    func configureTheme(theme: Theme) {
        self.messageLabel.textColor = theme.mainColors.chat.text
        self.nameLabel.textColor = theme.mainColors.chat.text
        
        self.backgroundColor = theme.mainColors.primaryBackground
        self.bubbleView.backgroundColor = theme.mainColors.chat.yourMessageBackground
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageLabel.text = ""
        nameLabel.text = ""
    }
    
}

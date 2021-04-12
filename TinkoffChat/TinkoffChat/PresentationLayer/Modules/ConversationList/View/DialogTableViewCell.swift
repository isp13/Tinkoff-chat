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
    
    @IBOutlet weak var channelImageVIew: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(with model: Channel_db) {
        self.nameLabel.text = model.name
        
        if let chatMessage = model.lastMessage {
            self.messageLabel.text = chatMessage
        } else {
            self.messageLabel.text = "Empty message"
        }
        
        self.dataLabel.text = model.lastActivity?.chatDateRepresentation()
        
        self.channelImageVIew.backgroundColor = .gray// заглушка 
    }
    
    func configureTheme(theme: Theme) {
        self.nameLabel.textColor = theme.mainColors.chatList.text
        self.messageLabel.textColor = theme.mainColors.chatList.text
        self.dataLabel.textColor = theme.mainColors.chatList.text
        
        self.backgroundColor = theme.mainColors.chatList.cellBackground
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        messageLabel.text = ""
        dataLabel.text = ""
    }
    
}

private func randomColor() -> UIColor {
    let red = CGFloat(drand48())
    let green = CGFloat(drand48())
    let blue = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}

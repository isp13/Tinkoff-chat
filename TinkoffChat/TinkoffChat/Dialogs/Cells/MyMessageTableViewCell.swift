//
//  MyMesTableViewCell.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 02.03.2021.
//

import UIKit

class MyMessageTableViewCell: UITableViewCell {

    @IBOutlet weak private var messageLabel: UILabel!
    
    var message: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configure(_ message: String?) {
        if let mes = message {
            messageLabel.text = mes
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

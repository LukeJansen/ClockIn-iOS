//
//  SettingsTableViewCell.swift
//  ClockIn
//
//  Created by Luke Jansen on 03/03/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    
    var string: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(){
        cellLabel.text = string
    }

}

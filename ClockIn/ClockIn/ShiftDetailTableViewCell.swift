//
//  ShiftDetailTableViewCell.swift
//  ClockIn
//
//  Created by Luke Jansen on 01/03/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit

class ShiftDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    var title: String!
    var data: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(){
        titleLabel.text = title;
        dataLabel.text = data;
    }

}

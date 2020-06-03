//
//  ShiftTableViewCell.swift
//  ClockIn
//
//  Created by Luke Jansen on 28/02/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var cellShift: Shift!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(shift: Shift){
        
        cellShift = shift
        
        let shiftDate = Utility.DateToString(date: cellShift.startDate, dateStyle: .medium, timeStyle: .none)
        
        let shiftTime = "\(Utility.DateToString(date: cellShift.startDate, dateStyle: .none, timeStyle: .short)) - \(Utility.DateToString(date: cellShift.finishDate, dateStyle: .none, timeStyle: .short))"
        
        locationLabel.text = cellShift.location
        roleLabel.text = cellShift.role
        dateLabel.text = shiftDate
        timeLabel.text = shiftTime
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ShiftDetailTableViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 01/03/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit

class ShiftDetailTableViewController: UITableViewController {
    
    var shift: Shift!
    var sectionList = ["Shift Info", "ClockIn Times"]
    var rowsInSection = [4,3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInSection[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! ShiftDetailTableViewCell
        
        if (indexPath.section == 0){
        
            switch (indexPath.row){
                case 0:
                    cell.title = "Location:"
                    cell.data = shift.location
                case 1:
                    cell.title = "Role:"
                    cell.data = shift.role
                case 2:
                    cell.title = "Start Time:"
                    cell.data = Utility.DateToString(date: shift.startDate, dateStyle: .short, timeStyle: .short)
                case 3:
                    cell.title = "Finish Time:"
                    cell.data = Utility.DateToString(date: shift.finishDate, dateStyle: .short, timeStyle: .short)
            
                default:
                    print("Too many rows!")
            }
        }
        else if (indexPath.section == 1){
            switch (indexPath.row){
                case 0:
                    cell.title = "ClockIn:"
                    if (shift.clockIn == nil){
                        cell.data = "Not Clocked In!"
                    } else {
                        cell.data = Utility.DateToString(date: shift.clockIn!, dateStyle: .none, timeStyle: .short)
                    }
                case 1:
                    cell.title = "ClockOut:"
                    if (shift.clockOut == nil){
                        cell.data = "Not Clocked Out!"
                    } else {
                        cell.data = Utility.DateToString(date: shift.clockOut!, dateStyle: .none, timeStyle: .short)
                    }
                case 2:
                    cell.title = "Length:"
                    if (shift.clockOut == nil || shift.clockIn == nil){
                        cell.data = "Shift Not Completed!"
                    } else {
                        let intervalFormatter = DateComponentsFormatter()
                        intervalFormatter.allowedUnits = [.hour, .minute, .second]
                        intervalFormatter.unitsStyle = .abbreviated
                        cell.data = intervalFormatter.string(from: shift.clockIn!, to: shift.clockOut!)
                    }
                default:
                    print("Something broke")
                
            }
        }
         
        cell.setupCell()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

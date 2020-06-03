//
//  SettingsTableViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 15/02/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var rowLabels: Dictionary<String, [String]> = ["Account Security": ["Change Password", "Log Out"], "Account Management": ["Personal Details"],]
    var dataManager: CoreDataManager!
    
    struct Settings{
        var sectionHeader: String!
        var rowLabels: [String]!
    }
    
    var settingsArray = [Settings]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        dataManager = CoreDataManager.shared
        
        for (key, value) in rowLabels{
            settingsArray.append(Settings(sectionHeader: key, rowLabels: value))
        }
        
        settingsArray.sort(by: {$0.sectionHeader < $1.sectionHeader})
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsArray[section].rowLabels.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsArray[section].sectionHeader
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> SettingsTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingsTableViewCell

        cell.string = settingsArray[indexPath.section].rowLabels[indexPath.row]
        cell.configure()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let label = settingsArray[indexPath.section].rowLabels[indexPath.row]
        
        switch label {
        case "Personal Details":
            if let controller = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "PersonalView") as? PersonalDetailsViewController{
                present(controller, animated: true, completion: nil)
            }
        case "Change Password":
            if let controller = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "PasswordView") as? PasswordChangeViewController{
                present(controller, animated: true, completion: nil)
            }
        case "Log Out":
            let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?!", preferredStyle: .alert)
            
            
            
            alert.addAction(UIAlertAction(title:"Yes", style: .cancel, handler: { (action) -> Void in
                self.dataManager.clearKeychain()
                if let controller = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "LoginView") as? LoginViewController{
                    self.present(controller, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title:"No", style: .default, handler: { (action) -> Void in
                if let indexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }))
            
            present(alert, animated: true, completion: nil)
        default:
            print("Case not defined!")
        }
        
    }

}

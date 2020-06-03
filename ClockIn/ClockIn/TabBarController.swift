//
//  TabBarController.swift
//  ClockIn
//
//  Created by Luke Jansen on 27/03/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    let clockInVC = ClockInViewController()
    let shiftsVC = ShiftTableViewController()
    let settingsVC = SettingsTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clockInVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        shiftsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
        settingsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        
        let tabBarList = [clockInVC, shiftsVC, settingsVC]

        viewControllers = tabBarList
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

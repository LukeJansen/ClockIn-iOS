//
//  LaunchScreenViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 04/04/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    
    var container: NSPersistentContainer!
    var dataManager: CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = CoreDataManager.shared.container
        dataManager = CoreDataManager.shared
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)

        if (dataManager.loadFromKeychain()){
            
            progressBar.setProgress(0.3, animated: true)
            
            dataManager.generateAccessToken()
            
            progressBar.setProgress(0.6, animated: true)
            
            dataManager.fetchData()
            progressBar.setProgress(1, animated: true)
            
            segue()
        }
        else{
            if let controller = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "LoginView") as? LoginViewController{
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func segue(){
        performSegue(withIdentifier: "start", sender: nil)
    }
}

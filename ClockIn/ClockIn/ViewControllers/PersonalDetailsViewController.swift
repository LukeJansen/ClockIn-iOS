//
//  PersonalDetailsViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 22/05/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PersonalDetailsViewController: UIViewController {

    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    
    var dataManager: CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataManager = CoreDataManager.shared
        
        let parameters: Parameters = ["UserID": dataManager.UserID!]
        let headers: HTTPHeaders = [.authorization(bearerToken: dataManager.AccessToken!)]
        
        AF.request(Utility.APIurl + "users/single/\(dataManager.UserID!)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            print(response)
            
            let json = try? JSON(data: response.data!)
            
            switch (response.result){
                case .success:
                    self.firstNameText.text = json!["FirstName"].stringValue
                    self.lastNameText.text = json!["LastName"].stringValue
                    self.emailText.text = json!["Email"].stringValue
                    self.phoneText.text = json!["Phone"].stringValue
                case .failure:
                    print("Could not connect!")
            }
        }
    }
    
    func validationCheck() -> Bool{
        if (firstNameText.text!.isEmpty || lastNameText.text!.isEmpty || phoneText.text!.isEmpty || emailText.text!.isEmpty){
            return false
        }
        else if (phoneText.text!.count != 11 || !emailText.text!.contains("@") || !emailText.text!.contains(".")){
            return false
        }
        else{
            return true
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        if (validationCheck()){
            let parameters: Parameters = ["FirstName": firstNameText.text!, "LastName": lastNameText.text!, "Email": emailText.text!, "Phone": phoneText.text!]
            let headers: HTTPHeaders = [.authorization(bearerToken: dataManager.AccessToken!)]
            
            AF.request(Utility.APIurl + "users/\(dataManager.UserID!)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                print(response)
                
                switch (response.result){
                    case .success:
                        self.dismiss(animated: true, completion: nil)
                    case .failure:
                        print("Could not connect!")
                }
            }
        } else{
            let alert = UIAlertController(title: "Validation Failed", message: "Please make sure all fields are filled in correctly", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil);
        }
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

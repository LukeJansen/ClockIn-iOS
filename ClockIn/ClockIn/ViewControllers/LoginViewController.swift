//
//  LoginViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 18/05/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    
    var dataManager: CoreDataManager!
    
    override func viewDidAppear(_ animated: Bool) {
        emailTextBox.delegate = self
        passwordTextBox.delegate = self
        
        dataManager = CoreDataManager.shared
    }
    
    func Login(){
        let email = emailTextBox.text!
        let pass = passwordTextBox.text!
        
        let parameters = ["Email": email, "Password": pass]
        
        AF.request(Utility.AUTHurl + "login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            let json = try? JSON(data: response.data!)
            let responseString = json!["message"].stringValue
            
            print(responseString)
            
            switch responseString {
                case "Logged In":
                    self.dataManager.RefreshToken = json!["RefreshToken"].stringValue
                    self.dataManager.UserID = json!["UserID"].stringValue
                    self.dataManager.UserType = json!["UserType"].intValue
                    
                    self.dataManager.saveToKeychain()
                
                    if let controller = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "TabBarView") as? UITabBarController{
                        self.present(controller, animated: true, completion: nil)
                    }
                case "Cannot Find User", "Bad Credentials":
                    self.showAlert(title: "Login Failed", message: "You entered an incorrect email & password combination!")
                default:
                    print("Response not defined!")
            }
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        Login()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField == emailTextBox){
            passwordTextBox.becomeFirstResponder()
        }
        else {
            Login()
        }
        
        return true
    }
    
    func showAlert(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil);
        }
    }
}

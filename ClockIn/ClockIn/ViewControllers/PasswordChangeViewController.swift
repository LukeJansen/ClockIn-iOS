//
//  PasswordChangeViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 22/05/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PasswordChangeViewController: UIViewController {

    @IBOutlet weak var currentPass: UITextField!
    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    
    var dataManager: CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataManager = CoreDataManager.shared
        
        // Do any additional setup after loading the view.
    }
    
    func validationCheck() -> String{
        if (currentPass.text!.isEmpty || newPass.text!.isEmpty || confirmPass.text!.isEmpty){
            return "Not all fields are filled in"
        }
        else if (newPass.text! != confirmPass.text!){
            return "New and Confirm Password must match"
        }
        else{
            return "Correct"
        }
    }
    
    @IBAction func changeButtonClicked(_ sender: Any) {
        
        let result = validationCheck()
        
        if (result == "Correct"){
            let parameters: Parameters = ["CurrentPass": currentPass.text!, "NewPass": newPass.text!, "UserID": dataManager.UserID!]
            let headers: HTTPHeaders = [.authorization(bearerToken: dataManager.AccessToken!)]
            
            AF.request(Utility.AUTHurl + "passwordChange", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                let json = try? JSON(data: response.data!)
                let responseString = json!["message"].stringValue
                
                switch (response.result){
                    case .success:
                        if (responseString == "Password Changed") {
                            self.dismiss(animated: true, completion: nil)
                            self.showAlert(responseString)
                        } else{
                            self.showAlert(responseString)
                        }
                    case .failure:
                        print("Could not connect!")
                }
            }
        } else{
            self.showAlert(result)
        }
    }
    
    func showAlert(_ message: String){
        let alert = UIAlertController(title: "Validation Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil);
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

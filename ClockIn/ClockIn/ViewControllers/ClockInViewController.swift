//
//  FirstViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 08/02/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit
import CoreNFC
import CoreData
import Alamofire
import SwiftyJSON

class ClockInViewController: UIViewController, NFCNDEFReaderSessionDelegate {

    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var clockInButton: UIButton!
    
    var container: NSPersistentContainer!
    var dataManager: CoreDataManager!
    
    var shiftList: [Shift]!
    var selectedShift: Shift!
    
    var nfcSession: NFCNDEFReaderSession?
    var available = false
    var nfcText: String!
    
    var clockedIn: Bool = false
    var timer: Timer!
    
    let workText = "SecureText"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager = CoreDataManager.shared
        container = dataManager.container
        
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkCapability()
        getShiftsForToday()
        checkClockStatus()
    }
    
    //MARK: - CoreNFC Code
    
    func checkCapability(){
        available = NFCNDEFReaderSession.readingAvailable
        clockInButton.isEnabled = available
        if (!available){
            showAlert(title: "Phone Incompatible", message: "This app requires NFC Reading Capabilities which your phone does not have! \nPlease speak to the ClockIn Manager in your organisation!")
        }
    }

    @IBAction func ScanBtn(_ sender: Any) {
        if (shiftList.count > 1){
            if (!clockedIn){
                let alert = UIAlertController(title: "Select Shift", message: "Please select a shift to ClockIn to!", preferredStyle: .actionSheet)
                for (shift) in shiftList{
                    let action = UIAlertAction(title: shift.location + " - " + Utility.DateToString(date: shift.startDate, dateStyle: .none, timeStyle: .short),
                                               style: .default, handler: { (action) -> Void in
                                                self.selectedShift = shift
                                                self.beginNFCReading()
                    })
                    
                    alert.addAction(action)
                }
                
                alert.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            }
            else {
                self.beginNFCReading()
            }
        } else if (shiftList.count <= 0){
            let alert = UIAlertController(title: "No Shifts!", message: "You either do not have any shifts assigned to you for today or have completed all assigned shifts!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        else {
            selectedShift = shiftList[0]
            beginNFCReading()
        }
    }
    
    func beginNFCReading(){
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Please scan your workplace's ClockIn card!"
        nfcSession?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Session Invalidated: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        for payload in messages[0].records{
            result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf16) ?? endSession("Format Not Supported!")
        }
        if (result != "ERROR"){
            //nfcSession?.invalidate(errorMessage: "ClockIn Card Detected!")
            nfcSession?.alertMessage = "Detected";
        }
        else{
            //nfcSession?.invalidate(errorMessage: "An Error Has Occured, See Alert!")
            nfcSession?.alertMessage = "Error";
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.nfcSession?.invalidate()
            self.nfcText = result;
            self.ClockIn()
        }
    }
    
    func endSession(_ message: String) -> String{
        showAlert(title: "Error!", message: message)
        return "ERROR";
    }
    
    func ClockIn(){
        if (nfcText == workText) {
            
            Utility.CheckAccessToken(dataManager: dataManager)
            
            let url: String
            var title, message: String
            var responseString = ""
            
            if (!clockedIn) {
                url = Utility.APIurl + "clock/in"
                title = "ClockedIn!"
                message = "ClockIn Successful!"
            } else{
                url = Utility.APIurl + "clock/out"
                title = "ClockedOut!"
                message = "ClockOut Successful!"
            }
            
            let parameters = ["ShiftID": selectedShift.id, "UserID": dataManager.UserID]
            let headers: HTTPHeaders = [.authorization(bearerToken: dataManager.AccessToken)]
            
            AF.request(url, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                let json = try? JSON(data: response.data!)
                responseString = json!["message"].stringValue
                
                print("Response: \(responseString)")
                
                switch (response.result){
                    case .success:
                        if (responseString == "User clocked in!" || responseString == "User clocked out!"){
                            self.dataManager.fetchData()
                            DispatchQueue.main.async{
                                self.showAlert(title: title, message: message)
                                self.getShiftsForToday()
                                self.checkClockStatus()
                            }
                        } else {
                            self.showAlert(title: "Error", message: "Something went wrong! \n\(responseString)")
                        }
                    case .failure:
                        self.showAlert(title: "Connection Failure", message: "Could not connect to ClockIn Service")
                }
            }            
        } else{
            showAlert(title: "ClockIn Fail", message: "The card you scanned did not match your workplaces card! If you are scanning your workplaces card please speak to the ClockIn Manager in your organisation!")
        }
    }
    
    //MARK: - CoreData Code
    
    func getShiftsForToday(){
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.init(abbreviation: TimeZone.current.abbreviation() ?? "")!
        
        let todayStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let todayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart)!
        
        let datePredicate = NSPredicate(format: "startDate >= %@ AND startDate <= %@", todayStart as NSDate, todayEnd as NSDate)
        
        let fetchRequest = Shift.createFetchRequest()
        fetchRequest.predicate = datePredicate
        do{
            try shiftList = container.viewContext.fetch(fetchRequest)
            print("Clock In View Fetched \(shiftList.count) shifts")
        }catch{
            print("Fetch failed")
        }
        
        for shift in shiftList{
            if (shift.clockIn != nil && shift.clockOut != nil){
                shiftList.remove(at: shiftList.firstIndex(of: shift)!)
            }
        }
    }
    
    //MARK: - Custom Code
    
    func checkClockStatus(){
        for shift in shiftList{
            if (shift.clockIn != nil && shift.clockOut == nil){
                clockedIn = true
                selectedShift = shift
                print("CLOCKED IN")
                
                if let image = UIImage(named: "ClockOut"){
                    clockInButton.setImage(image, for: .normal)
                }
                
                let intervalFormatter = DateComponentsFormatter()
                intervalFormatter.allowedUnits = [.hour, .minute, .second]
                intervalFormatter.unitsStyle = .positional
                let length = intervalFormatter.string(from: shift.clockIn!, to: Date())!
                
                textBox.text = "You are currently clocked in! \n\(shift.location) - \(shift.role) - \(Utility.DateToString(date: shift.startDate, dateStyle: .none, timeStyle: .short)) \nClockedIn For: \(length)"
                
                return
            }
        }
        
        if let image = UIImage(named: "ClockIn"){
            clockInButton.setImage(image, for: .normal)
        }
        textBox.text = "Push the button below to ClockIn!"
        clockedIn = false
    }
    
    @objc func fireTimer(){
        if (clockedIn){
            let intervalFormatter = DateComponentsFormatter()
            intervalFormatter.allowedUnits = [.hour, .minute, .second]
            intervalFormatter.unitsStyle = .abbreviated
            let length = intervalFormatter.string(from: selectedShift.clockIn!, to: Date())!
            
            textBox.text = "You are currently clocked in! \n\(selectedShift.location) - \(selectedShift.role) - \(Utility.DateToString(date: selectedShift.startDate, dateStyle: .none, timeStyle: .short)) \nClockedIn For: \(length)"
        }
    }
    
    func showAlert(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
                self.checkClockStatus()
            }))
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


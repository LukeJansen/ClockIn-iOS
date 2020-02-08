//
//  FirstViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 08/02/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit
import CoreNFC

class ClockInViewController: UIViewController, NFCNDEFReaderSessionDelegate {

    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var clockInButton: UIButton!
    
    var nfcSession: NFCNDEFReaderSession?
    var available = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkCapability()
    }
    
    func checkCapability(){
        available = NFCNDEFReaderSession.readingAvailable
        clockInButton.isEnabled = available
        if (!available){
            showAlert(title: "Phone Incompatible", message: "This app requires NFC Reading Capabilities which your phone does not have! \nPlease speak to the ClockIn Manager in your organisation!")
        }
    }

    @IBAction func ScanBtn(_ sender: Any) {
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
            self.textBox.text = result;
        }
    }
    
    func endSession(_ message: String) -> String{
        showAlert(title: "Error!", message: message)
        return "ERROR";
    }
    
    func showAlert(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


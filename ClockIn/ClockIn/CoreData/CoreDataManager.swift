//
//  CoreDataManager.swift
//  ClockIn
//
//  Created by Luke Jansen on 08/04/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import Alamofire
import KeychainSwift

class CoreDataManager{
    
    static let shared = CoreDataManager(name: "ClockIn")
    
    var container: NSPersistentContainer!
    
    var UserID: String!
    var RefreshToken: String!
    var AccessToken: String!
    var UserType: Int!
    
    private init(name: String){        
        container = NSPersistentContainer(name: name)
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error{
                print("Persistent Store Erorr: \(error)")
            }
        }
    }
    
    func saveContext(){
        if container.viewContext.hasChanges{
            do{
                try container.viewContext.save()
            } catch{
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    func fetchData(){
        Utility.CheckAccessToken(dataManager: self)
        
        let headers: HTTPHeaders = [.authorization(bearerToken: AccessToken!)]
        
        AF.request(Utility.APIurl + "shifts/\(UserID!)", method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    
            switch (response.result){
                case .success:
                    let json = try? JSON(data: response.data!)
                    
                    let jsonShiftsArray = json!.arrayValue
                    
                    print("Recieved \(jsonShiftsArray.count) shifts!")
                    
                    self.deleteShifts(jsonArray: jsonShiftsArray)
                    
                    DispatchQueue.main.async { [unowned self] in
                        for jsonShift in jsonShiftsArray {
                            let shift = Shift(context: self.container.viewContext)
                            
                            self.configure(shift: shift, usingJSON: jsonShift)
                        }
                        
                        self.saveContext()
                    }
                case .failure:
                    print("Internet failed!")
            }
        }
    }
    
    func configure(shift: Shift, usingJSON json: JSON){
        
        shift.location = json["Location"].stringValue
        shift.role = json["Role"].stringValue
        shift.start = json["Start"].stringValue
        shift.finish = json["Finish"].stringValue
        shift.id = json["_id"].stringValue

        let dateFormatter = ISO8601DateFormatter()

        shift.startDate = dateFormatter.date(from: shift.start)!
        shift.finishDate = dateFormatter.date(from: shift.finish)!

        shift.week = Utility.GetWeekFromDate(date: shift.startDate)
        
        let clockIn:  Dictionary<String,JSON> = json["ClockIn"].dictionaryValue
        let clockOut: Dictionary<String,JSON> = json["ClockOut"].dictionaryValue
        
        if (clockIn[UserID] != nil) {
            let time = clockIn[UserID]!.stringValue.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
            print(time)
            shift.clockIn = dateFormatter.date(from: time)
        }
        if (clockOut[UserID] != nil) {
            let time = clockOut[UserID]!.stringValue.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
            print(time)
            shift.clockOut = dateFormatter.date(from: time)
        }
    }
    
    func deleteShifts(jsonArray: [JSON]){
        var uniqueIds: [String] = []
        for jsonShift in jsonArray{
            uniqueIds.append(jsonShift["_id"].stringValue)
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shift")
        let predicate = NSPredicate(format: "NOT id IN %@", uniqueIds)
        
        fetchRequest.predicate = predicate
            
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try container.viewContext.execute(deleteRequest)
        } catch let error as NSError{
            print(error)
        }
    }
    
    func saveToKeychain(){
        let keychain = KeychainSwift()
        if !keychain.set(UserID, forKey: "UserID") {
            print("Saving userid failed!")
        }
        if !keychain.set(RefreshToken, forKey: "RefreshToken"){
            print("Saving refreshtoken failed!")
        }
        if keychain.set(String(UserType), forKey: "UserType"){
            print("Saving UserType failed!")
        }
    }
    
    func loadFromKeychain() -> Bool{
        let keychain = KeychainSwift()
        if let userID = keychain.get("UserID"), let refreshToken = keychain.get("RefreshToken"), let userType = keychain.get("UserType") {
            UserID = userID
            RefreshToken = refreshToken
            UserType = Int(userType)
            return true
        } else{
            return false
        }
    }
    
    func clearKeychain(){
        let keychain = KeychainSwift()
        keychain.clear()
    }
    
    func generateAccessToken(){
        
        let group = DispatchGroup()
        group.enter()
        
        let queue = DispatchQueue.global(qos: .default)
            
        queue.async{
            let parameters = ["UserID": self.UserID, "RefreshToken": self.RefreshToken]
            
            AF.request(Utility.AUTHurl + "token/refresh", method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseJSON(queue: queue) { response in
                
                let json = try? JSON(data: response.data!)
                let responseString = json!["message"].stringValue
                
                print(responseString)
                
                self.AccessToken = json!["AccessToken"].stringValue
                
                group.leave()
            }
        }
        group.wait()
    }
}

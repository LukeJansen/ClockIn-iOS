//
//  Utility.swift
//  ClockIn
//
//  Created by Luke Jansen on 01/03/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//
extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}

extension Date {
    var currentWeekMonday: Date {
        return Calendar.iso8601.date(from: Calendar.iso8601.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}

class Utility{
    
    static var APIurl = "https://api.clockin.uk/"
    static var AUTHurl = "https://auth.clockin.uk/"
//    static var APIurl = "http://192.168.0.63:3000/"
//    static var AUTHurl = "http://192.168.0.63:4000/"

    static func DateToString(date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String{
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        
        return formatter.string(from: date)
    }
    
    static func GetWeeksFromList(list: [Shift]) -> [Date]{
        var weekList: [Date] = []
        
        list.forEach { shift in
            let weekStart = GetWeekFromDate(date: shift.startDate)
            if (!weekList.contains(weekStart)){
                weekList.append(weekStart)
            }
        }
        
        return weekList.sorted(by: >)
    }
    
    static func GetWeekFromDate(date: Date) -> Date{
        return date.currentWeekMonday;
    }
    
    static func CheckAccessToken(dataManager: CoreDataManager) {
        let parameters: Parameters = ["AccessToken": dataManager.AccessToken!, "UserType": 0]
        
        AF.request(AUTHurl + "token/check", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print(response)
            
            let json = try? JSON(data: response.data!)
            let responseString = json!["message"].stringValue
            
            print("Response: \(responseString)")
            
            switch (response.result){
                case .success:
                    if (responseString == "jwt expired"){
                        dataManager.generateAccessToken()
                    }
                case .failure:
                    print("Could not connect!")
            }
        }
    }
}

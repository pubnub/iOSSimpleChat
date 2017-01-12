//
//  User+CoreDataClass.swift
//  
//
//  Created by Jordan Zucker on 1/11/17.
//
//

import Foundation
import CoreData

let UserIdentifierKey = "UserIdentifierKey"


public class User: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        identifier = UUID().uuidString
    }
    
//    private static var _userID: String? {
//        if let existingUserID = UserDefaults.standard.object(forKey: UserIdentifierKey) {
//            _userID = existingUserID as! String
//        } else {
//            let uuidString = UUID().uuidString
//            UserDefaults.standard.set(uuidString, forKey: UserIdentifierKey)
//            _userID = uuidString
//        }
//        return _userID
//    }
    
//    static var userID: String {
//        if _userID
//    }
    
    static var userID: String {
        if let existingUserID = UserDefaults.standard.object(forKey: UserIdentifierKey) {
            return existingUserID as! String
        } else {
            let uuidString = UUID().uuidString
            UserDefaults.standard.set(uuidString, forKey: UserIdentifierKey)
            return uuidString
        }
    }

}

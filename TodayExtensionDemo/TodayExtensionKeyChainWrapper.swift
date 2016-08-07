//
//  TodayExtensionKeyChainWrapper.swift
//  TodayExtensionDemo
//
//  Created by Kamal Ahuja on 8/4/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import Foundation

class TodayExtensionKeyChainWrapper{
    func getKeyChainItem( serviceName : String, accountName : String) -> NSData? {
        var returnValue : NSData?;
        let retrieveKeyChain : [NSString : AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : serviceName,
            kSecAttrAccount : accountName,
            kSecReturnAttributes : true,   // return dictionary in result parameter
            kSecReturnData : true          // include the password value
        ]
        var result : AnyObject?
        let err = SecItemCopyMatching(retrieveKeyChain, &result)
        if (err == errSecSuccess) {
            // on success cast the result to a dictionary and extract the
            // username and password from the dictionary.
             if let result = result as? [NSString : AnyObject],
               let accountName = result[kSecAttrAccount] as? String,
                let passwordData = result[kSecValueData] as? NSData {
                print("Account Found \(accountName)")
                returnValue = passwordData
            }
            if let result = result as? NSData {
                returnValue = result
            }
            
        } else if (err == errSecItemNotFound) {
            
            //Add if not found
            
            print("password not found")
        } else {
            // probably a program error,
            // print and lookup err code (e.g., -50 = bad parameter)
            print("Error finding password")
        }
        return returnValue;
    }
    
    func updateKeyChainItem(serviceName: String, accountName : String, updatedData : NSData) -> Bool {
        
        var isUpdateSuccess : Bool = false
        //Check if keychain already exists
        let retrieveKeyChain : [NSString : AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : serviceName,
            kSecAttrAccount : accountName,
            kSecReturnAttributes : true,   // return dictionary in result parameter
            kSecReturnData : true          // include the password value
        ]
        var result : AnyObject?
        let err = SecItemCopyMatching(retrieveKeyChain, &result)
        if (err == errSecSuccess) {
            //If keychain Item exist then update it. We print on console for debugging
//            if let result = result as? [NSString : AnyObject],
//                let accountName = result[kSecAttrAccount] as? String,
//                let passwordData = result[kSecValueData] as? NSData,
//                let actualPassword = NSString(data:passwordData, encoding:NSUTF8StringEncoding) as? String {
//                print("password found::\(actualPassword)")
//                print("password found::\(accountName)")
//            }
            
            //Updting keychain if found
            let array1ToBeUpdated = NSArray(objects: updatedData, serviceName)
            let array2ToBeUpdated = NSArray(objects:"\(kSecValueData)", "\(kSecAttrService)")
            let queryToBeUpdated = NSDictionary(objects: array1ToBeUpdated as [AnyObject], forKeys: array2ToBeUpdated as! [NSCopying])
            let retrieveKeyChain : [NSString : AnyObject] = [
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : serviceName,
                kSecAttrAccount : accountName
            ]
            let resultUpdate =  SecItemUpdate(retrieveKeyChain as CFDictionaryRef, queryToBeUpdated as CFDictionaryRef)
            
            //This is for debugging
            print(resultUpdate)
            isUpdateSuccess = true;
            
        } else if (err == errSecItemNotFound) {
            let addQuery : [NSString : AnyObject] = [
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : serviceName,
                kSecAttrAccount : accountName,
                kSecValueData : updatedData
            ]
            // if not found
            isUpdateSuccess = false
            print("Keychain item does not exist. Trying to Add now")
            var addResult : AnyObject?
            let addErr = SecItemAdd(addQuery, &addResult)
            if (addErr == errSecSuccess) {
                    print("Keychain item does not exist. We added Now")
                isUpdateSuccess = true
            } else {
                    print("Keychain item does not exist. And we could not add it")
            }
            
        } else {
            //If there is any other error
            isUpdateSuccess = false
            print("Error Occured while updating")
        }
        return isUpdateSuccess
    }
}
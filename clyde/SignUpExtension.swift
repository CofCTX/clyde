//
//  SignUpDataSource.swift
//  clydeClubIos
//
//  Created by Rahimi, Meena Nichole (Student) on 6/13/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore



extension SignUpViewController{
   
    
 
    //Error handler
    private func handleError(_ error: Error?, urlResponse: URLResponse? = nil){
        let errorDescription: String
        if let error = error {
            errorDescription = "\(error)"
        } else {
            errorDescription = "An unknown error occurred."
        }
        if (alert.isViewLoaded){
            alert.dismiss(animated: true)
        }
        alert = UIAlertController(title: "An error has occured. Account was not created.", message: errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in self.unwindToStart()}))
        present(self.alert, animated: true)
        SalesforceLogger.e(type(of:self), message: "Failed to complete REST request. \(errorDescription)")
     
    }
    
    //Uploads a contact account
    func uploadAccount(){
        SalesforceLogger.d(type(of: self), message: "Creating")
        alert = UIAlertController(title: nil, message: "Creating Account", preferredStyle: .alert)
        let loadingSymbol = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingSymbol.hidesWhenStopped = true
        loadingSymbol.style = .white
        loadingSymbol.startAnimating()
        present(alert, animated: true, completion: nil)
        self.createAccount()
        loadingSymbol.stopAnimating()
        alert.dismiss(animated: true, completion: nil)
    }
    
    
    //Creates a contact account
    private func createAccount(){
        print("Creating contact")
       
        //Creates a "record" and adds fields to it
        var record = [String: Any]()
        record["LastName"] = lastName
        record["FirstName"] = firstName
        //this needs to be changed or taken away
        record["Address_Comments__c"] = password.text
        record["Email"] = email.text
        record["AccountId"] = highSchoolId
        record["Birthdate"] = birthday.text
        record["Phone"] = phoneNumber.text
        record["TGTX_Master_Start_Term_and_Year__c"] = startTerm.text
        print("Requesting upsert")
        
        //Creates a request to upsert(creates or updates ObjectType)
        let upsertRequest = RestClient.shared.requestForUpsert(withObjectType: "Contact", externalIdField: "Id", externalId: nil, fields: record)
        print("Upsert Request Made")
        
        //Sends upsert request to Salesforce
        RestClient.shared.send(request: upsertRequest, onFailure: { (error, URLResponse) in
            SalesforceLogger.d(type(of: self), message: "Error invoking: \(error ?? "oh no" as! Error)")
            self.unwindToStart()
        }){(response, URLResponse) in
            os_log("\nSuccessful response received")
            self.segueNext()
            self.createUser()
        }
    }
    
    
    
    //Creates the user
    //This code will need to be "cleaned" up eventually
    func createUser( ){
        let formatName = "'\(name.text ?? "")'"
        var formatContact: String = ""
        
        //Creates a request for a soql query to get the user's id
        let request = RestClient.shared.request(forQuery: "SELECT Id FROM Contact WHERE Name = \(formatName)")
        
        //Sends soql request and saves the response in the appropriate variables
        RestClient.shared.send(request: request, onFailure: { (error, urlResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking: \(request)")
        }) { [weak self] (response, urlResponse) in
            
            if let JSON = response as? Dictionary<String,Any>{
                if let records = JSON["records"] as? [Dictionary<String, Any>]{
                    for record in records{
                        formatContact = record["Id"] as? String ?? ""
                        formatContact = "\(formatContact)"
                        self?.contactID = formatContact
                        
                        //Creates a new record and stores the appropriate fields.
                        var record = [String: Any]()
                        record["LastName"] = self!.lastName
                        record["FirstName"] = self!.firstName
                        record["Email"] = self!.email.text
                        record["Username"] = self!.email.text
                        record["Alias"] = self!.alias
                        record["TimeZoneSidKey"] = "America/New_York"
                        record["LocaleSidKey"] = "en_US"
                        record["ProfileId"] = "00eS0000000P58JIAS"
                        record["LanguageLocaleKey"] = "en_US"
                        record["ContactId"] = formatContact
                        record["EmailEncodingKey"] = "ISO-8859-1"
                        
                        
                        //Creates an upsert request to create/update the user with the matching Id
                        let upsertRequest = RestClient.shared.requestForUpsert(withObjectType: "User", externalIdField: "Id", externalId: nil, fields: record)
        
                        print("Request Made")
        
                        //Sends the upsert request
                        RestClient.shared.send(request: upsertRequest, onFailure: { (error, URLResponse) in   
                        }){(response, URLResponse) in
                            os_log("\nSuccessful response received")
                        }
                    }
                }
            }
        }
    }
    
    //Presents homepage
     private func unwindToStart(){
        wasSubmitted = true
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "unwindToMain", sender: self)
        }
    }
    
    //Presents confirm email page
     func segueNext(){
        wasSubmitted = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SegueToConfirmEmail", sender: self)
        }
    }
}

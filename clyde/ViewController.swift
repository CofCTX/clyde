//
//  ViewController.swift
//  clydeClubIos
//
//  Created by Rahimi, Meena Nichole (Student) on 6/18/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SafariServices
import SwiftyJSON
import SalesforceSDKCore
import SmartSync
import SmartStore


class HomeViewController: UIViewController{
    let defaults = UserDefaults.standard
    
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)!
    
    var storeO = SmartStore.shared(withName: SmartStore.defaultStoreName)
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "Home")

    @IBOutlet weak var menuBarItem: UIBarButtonItem!
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuBar(menuBarItem: menuBarItem)
        self.addLogoToNav()
        
    }
    
    func showInformationPopUp(){
        let popUp = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoPop") as! InfoPopUpViewController
        popUp.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(popUp, animated: true)    }


    override func loadView() {
        super.loadView()
       // self.loadFromStore()
        //self.loadDataIntoStore()
        self.loadData()
        self.loadSchools()
//        self.pullImage()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //self.loadView()
      // self.loadDataIntoStore()
        
    }
    /// Will present the article webpage when tapped
    ///
    /// - Parameter sender: the UIButton tapped
    @IBAction func clickFirst(_ sender: UIButton) {
        show("https://today.cofc.edu/2019/06/24/beat-the-heat-public-health-heat-related-illness/")}
    
    /// Will present the article webpage when tapped
    ///
    /// - Parameter sender: the UIButton tapped
    @IBAction func clickSecond(_ sender: UIButton) {
        show("https://today.cofc.edu/2019/06/21/jarrell-brantley-nba-draft/")}
    
    /// Will present the article webpage when tapped
    ///
    /// - Parameter sender: the UIButton tapped
    @IBAction func clickThird(_ sender: UIButton) {
        show("https://today.cofc.edu/2019/06/12/college-of-charleston-orientation-2019/")}
    
    /// Will present the article webpage when tapped
    ///
    /// - Parameter sender: the UIButton tapped
    @IBAction func clickMore(_ sender: UIButton) {
        show("https://today.cofc.edu/")}
    
    
    /// Displays the url as a Safari view controller
    ///
    /// - Parameter url: the url to be displayed.
    func show(_ url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
 
    
    
    
    
    func loadData(){
       
        let userIdRequest = RestClient.shared.requestForUserInfo()
        RestClient.shared.send(request: userIdRequest, onFailure: {(error, urlResponse) in
        }) { [weak self] (response, urlResponse) in
            let jsonResponse = JSON(response)
            let id = jsonResponse["user_id"].stringValue
            let email = jsonResponse["email"].stringValue
            DispatchQueue.main.async {
                self?.userId = id
                self!.defaults.set(id,forKey: "UserId")
            }
            let userIdRequest = RestClient.shared.request(forQuery: "Select Name, Id, Email, ContactId From User WHERE Id = '\(id)'")
            
            RestClient.shared.send(request: userIdRequest, onFailure: {(error, urlResponse) in
            }) { [weak self] (response, urlResponse) in
                guard let strongSelf = self,
                    let jsonResponse = response as? Dictionary<String, Any>,
                    let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                    else{
                        print("\nWeak or absent connection.")
                        return
                }
                let jsonContact = JSON(response)
                let contactId = jsonContact["records"][0]["ContactId"].stringValue
                self!.defaults.set(contactId, forKey: "ContactId")

                
                //SalesforceLogger.d(type(of: strongSelf), message:"Invoked: \(userIdRequest)")
                if ((((strongSelf.store.soupExists(forName: "User"))))) {
                    strongSelf.store.clearSoup("User")
                    strongSelf.store.upsert(entries: results, forSoupNamed: "User")
                    os_log("\n\n----------------------SmartStore loaded records for user.-------------------------------", log: strongSelf.mylog, type: .debug)
                }
                
                //Loads contactData into store
                let contactAccountRequest = RestClient.shared.request(forQuery: "SELECT OwnerId, MailingStreet, MailingCity, MailingPostalCode, MailingState, MobilePhone, Email, Name, Text_Message_Consent__c, Birthdate, TargetX_SRMb__Gender__c,TargetX_SRMb__Student_Type__c, Gender_Identity__c, Ethnicity_Non_Applicants__c,TargetX_SRMb__Graduation_Year__c, Honors_College_Interest_Check__c,Status_Category__c,First_Login__c, TargetX_SRMb__Anticipated_Major__c,Id  FROM Contact WHERE Email = '\(email)'")
                RestClient.shared.send(request: contactAccountRequest, onFailure: {(error, urlResponse) in
                }) { [weak self] (response, urlResponse) in
                    guard let strongSelf = self,
                        let jsonResponse = response as? Dictionary<String, Any>,
                        let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                        else{
                            print("\nWeak or absent connection.")
                            return
                    }
                    let jsonContact = JSON(response)
                    let counselorId = jsonContact["records"][0]["OwnerId"].stringValue
                    
                   // SalesforceLogger.d(type(of: strongSelf), message: "Invoked: \(contactAccountRequest)")
                    if (((strongSelf.store.soupExists(forName: "Contact")))){
                        strongSelf.store.clearSoup("Contact")
                        strongSelf.store.upsert(entries: results, forSoupNamed: "Contact")
                        os_log("\n\n----------------------SmartStore loaded records for contact.-------------------------------", log: strongSelf.mylog, type: .debug)
                    }
                    
                    //Loads counselor data into the store
                    let counselorAccountRequest = RestClient.shared.request(forQuery: "SELECT AboutMe, Email, Name,MobilePhone,Image_Url__c FROM User WHERE Id = '\(counselorId)'")
                    RestClient.shared.send(request: counselorAccountRequest, onFailure: {(error, urlResponse) in
                    }) { [weak self] (response, urlResponse) in
                        guard let strongSelf = self,
                            let jsonResponse = response as? Dictionary<String, Any>,
                            let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                            else{
                                print("\nWeak or absent connection.")
                                return
                        }
                     //   SalesforceLogger.d(type(of: strongSelf), message: "Invoked: \(counselorAccountRequest)")
                        if (((strongSelf.store.soupExists(forName: "Counselor")))){
                            strongSelf.store.clearSoup("Counselor")
                            strongSelf.store.upsert(entries: results, forSoupNamed: "Counselor")
                            os_log("\n\n----------------------SmartStore loaded records for counselor.-------------------------------", log: strongSelf.mylog, type: .debug)
                        }
                    }
                }
            }
            
            let majorRequest = RestClient.shared.request(forQuery: "SELECT Contact_Email__c,Description__c,Image_Url__c,Name,Website__c,Id FROM Possible_Interests__c WHERE Type__c = 'Major'")
            RestClient.shared.send(request: majorRequest, onFailure: {(error, urlResponse) in
            }) { [weak self] (response, urlResponse) in
                guard let strongSelf = self,
                    let jsonResponse = response as? Dictionary<String, Any>,
                    let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                    else{
                        print("\nWeak or absent connection.")
                        return
                }
               // SalesforceLogger.d(type(of: strongSelf), message:"Invoked: \(userIdRequest)")
                if (((strongSelf.store.soupExists(forName: "Major")))) {
                    strongSelf.store.clearSoup("Major")
                    strongSelf.store.upsert(entries: results, forSoupNamed: "Major")
                    os_log("\n\n----------------------SmartStore loaded records for majors.-------------------------------", log: strongSelf.mylog, type: .debug)
                }
        
            }
        }//completion
        
    }//func
        
    
    func loadSchools(){
        let schoolRequest = RestClient.shared.request(forQuery: "SELECT Name, Id From Account")
        RestClient.shared.send(request: schoolRequest, onFailure: {(error, urlResponse) in
            
            print("-----------------------------------------------------")
            print(error)
            
            
        }) { [weak self] (response, urlResponse) in
            guard let strongSelf = self,
                let jsonResponse = response as? Dictionary<String, Any>,
                let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                
                else{
                    print("\nWeak or absent connection.")
                    return
            }
            //SalesforceLogger.d(type(of: strongSelf), message: "Invoked: \(schoolRequest)")
            if (((strongSelf.store.soupExists(forName: "School")))){
                strongSelf.store.clearSoup("School")
                strongSelf.store.upsert(entries: results, forSoupNamed: "School")
                os_log("\n\n----------------------SmartStore loaded records for school.-------------------------------", log: strongSelf.mylog, type: .debug)
            }
        }
    }
    /// Loads important data into the offline storage
    func loadDataIntoStore(){
        //Loads user id into store
        let userIdRequest = RestClient.shared.request(forQuery: "Select Name, Id, Email, ContactId From User")
        //let userIdRequest = RestClient.shared.requestForUserInfo()
        RestClient.shared.send(request: userIdRequest, onFailure: {(error, urlResponse) in
        }) { [weak self] (response, urlResponse) in
            guard let strongSelf = self,
                let jsonResponse = response as? Dictionary<String, Any>,
                let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                else{
                    print("\nWeak or absent connection.")
                    return
            }
            
            

            SalesforceLogger.d(type(of: strongSelf), message:"Invoked: \(userIdRequest)")
            if ((((strongSelf.store.soupExists(forName: "User"))))) {
                strongSelf.store.clearSoup("User")
                strongSelf.store.upsert(entries: results, forSoupNamed: "User")
                os_log("\n\nSmartStore loaded records for user.", log: strongSelf.mylog, type: .debug)
            }

            //Loads contactData into store
            let contactAccountRequest = RestClient.shared.request(forQuery: "SELECT OwnerId, MailingStreet, MailingCity, MailingPostalCode, MailingState, MobilePhone, Email, Name, Text_Message_Consent__c, Birthdate, TargetX_SRMb__Gender__c,TargetX_SRMb__Student_Type__c, Gender_Identity__c, Ethnicity_Non_Applicants__c,TargetX_SRMb__Graduation_Year__c, Honors_College_Interest_Check__c,Status_Category__c,First_Login__c, TargetX_SRMb__Anticipated_Major__c,Id  FROM Contact")
            RestClient.shared.send(request: contactAccountRequest, onFailure: {(error, urlResponse) in
            }) { [weak self] (response, urlResponse) in
                guard let strongSelf = self,
                    let jsonResponse = response as? Dictionary<String, Any>,
                    let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                    else{
                        print("\nWeak or absent connection.")
                        return
                }
                let jsonContact = JSON(response)
                let counselorId = jsonContact["records"][0]["OwnerId"].stringValue
              
                SalesforceLogger.d(type(of: strongSelf), message: "Invoked: \(contactAccountRequest)")
                if (((strongSelf.store.soupExists(forName: "Contact")))){
                    strongSelf.store.clearSoup("Contact")
                    strongSelf.store.upsert(entries: results, forSoupNamed: "Contact")
                    os_log("\n\nSmartStore loaded records for contact.", log: strongSelf.mylog, type: .debug)
                }

                //Loads counselor data into the store
                let counselorAccountRequest = RestClient.shared.request(forQuery: "SELECT AboutMe, Email, Name,MobilePhone,Image_Url__c FROM User WHERE Id = '\(counselorId)'")
                RestClient.shared.send(request: counselorAccountRequest, onFailure: {(error, urlResponse) in
                }) { [weak self] (response, urlResponse) in
                    guard let strongSelf = self,
                        let jsonResponse = response as? Dictionary<String, Any>,
                        let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                        else{
                            print("\nWeak or absent connection.")
                            return
                    }
                    SalesforceLogger.d(type(of: strongSelf), message: "Invoked: \(counselorAccountRequest)")
                    if (((strongSelf.store.soupExists(forName: "Counselor")))){
                        strongSelf.store.clearSoup("Counselor")
                        strongSelf.store.upsert(entries: results, forSoupNamed: "Counselor")
                        os_log("\n\nSmartStore loaded records for counselor.", log: strongSelf.mylog, type: .debug)
                    }
                }
            }
        }
        
        let majorRequest = RestClient.shared.request(forQuery: "SELECT Contact_Email__c,Description__c,Image_Url__c,Name,Website__c,Id FROM Possible_Interests__c WHERE Type__c = 'Major'")
        RestClient.shared.send(request: majorRequest, onFailure: {(error, urlResponse) in
            print(error)
        }) { [weak self] (response, urlResponse) in
            guard let strongSelf = self,
                let jsonResponse = response as? Dictionary<String, Any>,
                let results = jsonResponse["records"] as? [Dictionary<String, Any>]
                else{
                    print("\nWeak or absent connection.")
                    return
            }
            SalesforceLogger.d(type(of: strongSelf), message:"Invoked: \(userIdRequest)")
            if (((strongSelf.store.soupExists(forName: "Major")))) {
                strongSelf.store.clearSoup("Major")
                strongSelf.store.upsert(entries: results, forSoupNamed: "Major")
                os_log("\n\nSmartStore loaded records for majors.", log: strongSelf.mylog, type: .debug)
            }
        }    }
    
    


    /// Loads data from store and presents on edit profile
    func loadFromStore(){
        if  let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {Contact:First_Login__c} from {Contact}", pageSize: 1),
            let smartStore = self.storeO,
            let record = try? smartStore.query(using: querySpec, startingFromPageIndex: 0) as? [[String]]{
            let firstTime = (record[0][0])
            DispatchQueue.main.async {
                if firstTime == "0"{
                    self.showInformationPopUp()
                }
            }
        }
        }


    func pullImage(){
        print("-----------------------------------------------------------")
        let id = defaults.string(forKey: "UserId")
        let userPhotoRequest = RestClient.shared.request(forQuery: "SELECT FullPhotoUrl FROM User WHERE Id = '\(id!)'")
        
        RestClient.shared.send(request: userPhotoRequest, onFailure: {(error, urlResponse) in
            print(error)
        }) { [weak self] (response, urlResponse) in
            guard let _ = self,
                let jsonResponse = response as? Dictionary<String, Any>,
                let _ = jsonResponse["records"] as? [Dictionary<String, Any>]
                else{
                    print("\nWeak or absent connection.")
                    return
            }
            let jsonContact = JSON(response)
            let pictureUrl = jsonContact["records"][0]["FullPhotoUrl"].stringValue
            
            DispatchQueue.main.async {
                let sep = pictureUrl.components(separatedBy: "portal/")
                let url = "https://c.cs40.content.force.com/" + sep[1]
                
                self!.defaults.set(url, forKey: "ProfilePhotoURL")            }
            
        }
        
    }
    



}//class
    
    
       

    


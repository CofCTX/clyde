//
//  MajorsViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 6/20/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SmartStore
import SwiftyJSON
import MessageUI
import SmartSync

class MajorsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    //--------------------------------------------------------------------------
    // MARK: Variables
    
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)!
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "Majors")
    var majorCounter: Int = 0
    var contactId = ""
    var interestName = ""
    var websiteUrl = ""
    var interestId = ""
    var email: String? = ""
    var preference = ""
    var selectedId =  ""
    
    //--------------------------------------------------------------------------
    // MARK: Outlets
    
    @IBOutlet weak var majorImage: UIImageView!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var majorDescription: UITextView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    
   
    //--------------------------------------------------------------------------
    // MARK: View Functions
    
    /// Overrides the viewDidLoad function. Adds the menu bar, adds the logo to the nav bar, adjusts font for major label and major description
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
        self.majorLabel.adjustsFontSizeToFitWidth = true
        self.majorDescription.adjustsFontForContentSizeCategory = true
    }
    
    override func loadView() {
        super.loadView()
        self.loadFromStore()
    }
    
    //-------------------------------------------------------------------------
    // MARK: Salesforce Functions

    
    /// SmartStore related function that loads data into variables.
    ///
    /// Loads from the 'Major' store:
    /// - Name - Email - Description - ImageUrl - Id - ContactEmail
    func loadFromStore(){
        // Creates the query spec. Query specs must be formatted in this way.
        let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {Major:Name},{Major:Website__c},{Major:Description__c},{Major:Image_Url__c}, {Major:Id}, {Major:Contact_Email__c} from {Major}", pageSize: 60)
        do{
            let records = try self.store.query(using: querySpec!, startingFromPageIndex: 0)
            guard let record = records as? [[String]] else{
                os_log("\nBad data returned from SmartStore query.", log: self.mylog, type: .debug)
                return
            }
            if majorCounter == record.count{
                majorCounter = 0
            }
            let name = record[self.majorCounter][0]
            let website = record[self.majorCounter][1]
            let description = record[self.majorCounter][2]
            let image = record[self.majorCounter][3]
            let id = record[self.majorCounter][4]
            let contactEmail = record[self.majorCounter][5]
            
            
            DispatchQueue.main.async {
                
                let url = URL(string: image)!
                let task = URLSession.shared.dataTask(with: url){ data,response, error in
                    guard let data = data, error == nil else {return}
                    DispatchQueue.main.async {
                        self.majorImage.image = UIImage(data:data)
                        self.majorCounter = self.majorCounter + 1
                        self.majorLabel.text = name
                        self.majorDescription.text = description
                        self.websiteUrl = website
                        self.interestName = name
                        self.interestId = id
                        self.email = contactEmail
                    }
                }
                task.resume()
            }
        }catch let e as Error?{
            print(e as Any)
        }
    }
    
    
    /// Salesforce related function that pushes the preference data for each major into Salesforce
    ///
    /// - Parameter button: preference button
    func pushUsingSalesforce(_ button: Int){
        var createRecord = [String : Any]()
        var updateRecord = [String : Any]()
       
        if button == 0{
            preference = "Dislike"
        } else if button == 1{
            preference = "Maybe"
        } else{
            preference = "Like"
        }
        
        createRecord["Preference__c"] = preference
        createRecord["Possible_Interest__c"] = interestId
        createRecord["Student__c"] = contactId
        updateRecord["Preference__c"] = preference
        
       
        
        let checkForExistingSelectedInterestRequest = RestClient.shared.request(forQuery: "SELECT Preference__c, Id FROM Selected_Interest__c WHERE Student__c = '\(contactId)' AND Possible_Interest__c = '\(interestId)'")
        RestClient.shared.send(request: checkForExistingSelectedInterestRequest, onFailure: {(error, urlResponse) in
        
            
            
            
        }) { [weak self] (response, urlResponse) in
            let jsonResponse = JSON(response!)
            
            let results = jsonResponse.dictionaryObject
            let totalSize = jsonResponse["totalSize"].intValue
           
            
            if totalSize == 0{
                let createSelectedInterestRequest = RestClient.shared.requestForCreate(withObjectType: "Selected_Interest__c", fields: createRecord)
                RestClient.shared.send(request: createSelectedInterestRequest, onFailure: { (error, URLResponse) in
                    SalesforceLogger.d(type(of:self!), message:"Error invoking while sending create request: \(createSelectedInterestRequest), error: \(String(describing: error))")
                    
                }){(response, URLResponse) in
                    //Creates a save alert to be presented whenever the user saves their information
                    os_log("\nSelected Interest successfully created")
                }
            }
            
            
            else if totalSize > 0{
                let id = jsonResponse["records"][0]["Id"].stringValue
                let updateSelectedInterestRequest = RestClient.shared.requestForUpdate(withObjectType: "Selected_Interest__c", objectId: id, fields: updateRecord)
                RestClient.shared.send(request: updateSelectedInterestRequest, onFailure: { (error, URLResponse) in
                    SalesforceLogger.d(type(of:self!), message:"Error invoking while sending update request: \(updateSelectedInterestRequest), error: \(String(describing: error))")
                    
                }){(response, URLResponse) in
                    //Creates a save alert to be presented whenever the user saves their information
                    os_log("\nSelected Interest successfully updated")
                }
            } else{
                print("This is a problem.")
            }
        }
    }
    
    
    //---------------------------------------------------------------------
    // MARK: Contact Functions
    
    /// Tells the delegate that the user wants to close the mail composition
    /// view.
    ///
    /// - Parameters:
    ///   - controller: The view controller that manages the mail composition view.
    ///   - result: The result of the user’s action.
    ///   - error: Contains an error, if an error occurs.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Sent")
        case MFMailComposeResult.failed.rawValue:
            print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    /// Website Action button that when pressed will present the department website of each major.
    ///
    /// - Parameter sender: website button
    @IBAction func WebsiteButton(_ sender: UIButton) {
        self.show(websiteUrl)
    }
    
    /// When button is tapped, will email the counselor.
    ///This will not work in the simulator.
    /// - Parameter sender: action button
    @IBAction func ContactButton(_ sender: UIButton) {
        if let email = self.email{
            //Email "settings", these can be changed to anything.
            let subject = "Question Sent From Clyde Club Regarding Major"
            let body = "Hi! This is a test email from Clyde Club. Clyde Club is an app that is being developed by the Office of Admissions. If you have any questions, please contact rahimimn@cofc.edu."
            let to = [email]
            //Creates the mail view, allows user to write an email to the contact for the major.
            let mailView: MFMailComposeViewController = MFMailComposeViewController()
            mailView.mailComposeDelegate = self
            mailView.setSubject(subject)
            mailView.setMessageBody(body, isHTML: false)
            mailView.setToRecipients(to)
            
            self.present(mailView, animated: true, completion: nil)
            
        }    }
    
    //Takes a url as a parameter, and then makes it appear with an internal safari page.
    func show(_ url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }    //------------------------------------------------------------------------
    // MARK: Preference Buttons
    
    /// Preference button: like, when pressed will load the next major, and save the user's preference for the major into Salesforce
    ///
    /// - Parameter sender: like button
    @IBAction func likeButton(_ sender: UIButton) {
        loadFromStore()
        let button = sender.tag
        pushUsingSalesforce(button)
    }
    
    
    /// Preference button: dislike, when pressed will load the next major, and save the user's preference for the major into Salesforce
    ///
    /// - Parameter sender: dislike button
    @IBAction func dislikeButton(_ sender: UIButton) {
        loadFromStore()
        let button = sender.tag
        pushUsingSalesforce(button)
    }
    
    
    /// Preference button: maybe, when pressed will load the next major, and save the user's preference for the major into Salesforce
    ///
    /// - Parameter sender: maybe button
    @IBAction func maybeButton(_ sender: UIButton) {
        loadFromStore()
        let button = sender.tag
        pushUsingSalesforce(button)
    }
}

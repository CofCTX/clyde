//
//  QuestionsViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 6/20/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import Foundation
import SalesforceSDKCore
import SwiftyJSON

 //TO-DO: Create a chat system between user and counselors or tour guides.

class QuestionsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.delegate = self
        //reveals menu
       self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
    }


    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var textInput: UITextField!
    
    @IBAction func send(_ sender: UIButton) {
        var record = [String: Any]()
        record["Test_Input__c"] = textInput.text
        let userRequest = RestClient.shared.requestForUpsert(withObjectType: "Test__c", externalIdField: "Id", externalId: "a3m540000006nvzAAA", fields: record)
        RestClient.shared.send(request: userRequest, onFailure: { (error, URLResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking while sending upsert request: \(userRequest)")
            //Creates a save alert to be presented whenever the user saves their information
        }){(response, URLResponse) in
            //Creates a save alert to be presented whenever the user saves their information
            let saveAlert = UIAlertController(title: "Information Saved", message: "Your information has been saved.", preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(saveAlert, animated: true)
            os_log("\nSuccessful response received")
        }
        
    }
   
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.textColor = UIColor.black
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
    }


    override func loadView() {
        super.loadView()
        let testRequest = RestClient.shared.request(forQuery: "SELECT Name,Test_Input__c FROM Test__c WHERE Name = 'Testing'")
        RestClient.shared.send(request: testRequest,onFailure: { (error, urlResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking on contact id request: \(testRequest), \(error) ")
        }) { [weak self] (response, urlResponse) in
            let testJson = JSON(response!)
            let name = testJson["records"][0]["Name"].stringValue
            let input = testJson["records"][0]["Test_Input__c"].stringValue
            DispatchQueue.main.async {
                self?.textInput.text = input
                self?.label.text = name
            }
        }
        
    }



}

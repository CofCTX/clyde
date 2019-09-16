//
//  InfoPopUpViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 8/5/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SmartSync

class InfoPopUpViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate {
    
    //Creates the store variable
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "infoPopUp")
    
    var counter = 0
    var questions = ["Your mobile number:", "Do you want to opt-in for mobile messaging?", "Your major interest?","Your street address:","Your city:","Your state", "Your zip code:","Your gender:", "Are you interested in the Honors College?","Your student type:",""]
    var salesforceTitles = ["MobilePhone","Text_Message_Consent__c","TargetX_SRMb__Anticipated_Major__c","MailingStreet","MailingCity", "MailingState","MailingPostalCode","TargetX_SRMb__Gender__c","Honors_College_Interest_Check_c","Status_Category__c"]
  
    var answers = [] as Array
    var genderOptions = ["Female","Male"]
    var studentTypeOptions = ["Freshman","Transfer"]
    var yesNoOptions = ["Yes","No"]
    
    let genderIdentityPicker = UIPickerView()
    let studentTypePicker = UIPickerView()
    let yesNoPicker = UIPickerView()
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var answer: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var question: UITextView!
    @IBOutlet weak var header: UILabel!
    
    
    @IBAction func nextQuestion(_ sender: UIButton) {
        
        answer.borderStyle = UITextField.BorderStyle.roundedRect
        self.answers.append(answer.text!)
        print(answers)
        question.text = questions[counter]
        header.text = "Clyde wants to know..."
        counter += 1
        if (counter + 1) == questions.count{
            sender.setTitle("Finish", for: [])
        }
        if (counter == questions.count){
            self.dismiss(animated: true, completion: nil)
            insertIntoSoup()
            syncUp()
        }
        
        answer.text = ""
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answer.delegate = self
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(cancelPicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton, doneButton], animated: false)
        answer.delegate = self
        answer.inputAccessoryView = toolbar
        genderIdentityPicker.delegate = self
        yesNoPicker.delegate = self
        studentTypePicker.delegate = self
        
    }
    
    /// Pulls data from the user form and upserts it into the "Contact" soup
    func insertIntoSoup(){
        
        let JSONData : [String:Any] = ["MobilePhone": answers[1],
                                       "Text_Message_Consent__c": answers[2],
                                       "TargetX_SRMb__Anticipated_Major__c": answers[3],
                                       "MailingStreet": answers[4],
                                       "MailingCity": answers[5],
                                       "MailingState": answers[6],
                                       "MailingPostalCode": answers[7],
                                       "TargetX_SRMb__Gender__c": answers[8],
                                       "Honors_College_Interest_Check_c": answers[9],
                                       "Status_Category__c": answers[10],
                                       "First_Login__c": 1,
                                       "__locally_deleted__": false,
                                       "__locally_updated__": true,
                                       "__locally_created__": false,
                                       "__local__": true,]
        print(JSONData)
       if (((self.store?.soupExists(forName: "Contact"))!)){
           // self.store?.clearSoup("Contact")
            self.store?.upsert(entries: [JSONData], forSoupNamed: "Contact")
           os_log("\n\nSmartStore loaded records for contact.", log: self.mylog, type: .debug)
       }
    }
    
    func syncUp(){
        if let smartStore = self.store,
            let  syncMgr = SyncManager.sharedInstance(store: smartStore) {
            do {
                try syncMgr.reSync(named: "syncUpContact") { [weak self] syncState in
                    if syncState.isDone() {
                        let alert = UIAlertController(title: "Information Saved", message: "Clyde Club saved your information.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        
                        self?.present(alert, animated: true)
                        
                    }
                }
            } catch {
                print("Unexpected sync error: \(error).")
            }
        }     }
    

    /// Method that returns a textfield's input
    ///
    /// - Parameter textfield: The textfield that will return.
    /// - Returns: Boolean on whether a textfield should return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.textColor = UIColor.black
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == genderIdentityPicker){
            return genderOptions.count
        }else if pickerView == yesNoPicker{
            return yesNoOptions.count
        }
        else{
            return studentTypeOptions.count
        }}
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == genderIdentityPicker){
            return genderOptions[row]
        }else if pickerView == yesNoPicker{
            return yesNoOptions[row]
        }
        else{
            return studentTypeOptions[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.genderIdentityPicker{
            self.answer.text = genderOptions[row]
        }else if pickerView == self.yesNoPicker{
            self.answer.text = yesNoOptions[row]
        }else{
            self.answer.text = studentTypeOptions[row]
        }
    }

}

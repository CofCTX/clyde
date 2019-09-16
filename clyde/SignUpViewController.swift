//
//  SignUpViewController.swift
//  clydeClubIos
//
//  Created by Rahimi, Meena Nichole (Student) on 6/12/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    var alert:UIAlertController!
    var wasSubmitted = false
    
    //fields
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var highSchool: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var startTerm: UITextField!
    
   
    

    
    
    @IBOutlet weak var alreadyHaveAnAccount: UIButton!
    
    //Presents the login page
    @IBAction func SegueToLogIn(_ sender: UIButton) {
        performSegue(withIdentifier: "SegueToLogIn", sender: self)
    }

    
    //birthday
    let datePicker = UIDatePicker()
    
    
    var firstName: String!
    var lastName: String!
    var highSchoolId: String!
    var alias: String!
    var contactID: String!
    
  
    //Creates a date picker object for the birthday field
    private func showDatePicker(){
        //formats date
        datePicker.datePickerMode = .date
        
        //toolbar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        birthday.inputAccessoryView = toolbar
        birthday.inputView = datePicker
        
    }
    
    //Determines when the user stops editing the date picker
    @objc func doneDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        birthday.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    //Ends editing of the date picker
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    //Determines whether the user successfully entered certain fields and then presents the confirm email page. At the moment, the highschoolid is hard coded for one school, this will need to be changed to allow for multiple schools.
    @IBAction func SignUpIsPressed(_ sender: Any) {
        if password != nil{
            print("Good to go.")
            let nameArray = name.text?.components(separatedBy: " ")
            firstName = nameArray![0]
            lastName = nameArray![1]
            alias = firstName.prefix(1)+lastName
            
            //this will need to be changed to allow for multiple high schools
            if highSchool.text == "West Ashley High"{
                highSchoolId = "001S000000zAt4SIAS"
                
            }
            uploadAccount()
            self.performSegue(withIdentifier: "SegueToConfirmEmail", sender: self)
        }
        else {
            print("No")
            //this is where we would add the username to the record
        }
    }
    
  
    //Changes the background color and text color when the user starts typing in the textfield
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textField.textColor = #colorLiteral(red: 0.558098033, green: 0.1014547695, blue: 0.1667655639, alpha: 1)
    }

    //Changes the background color when the user finishes typing in the textfield.
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    //Returns textfield's value
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.delegate = self
        password.delegate = self
        highSchool.delegate = self
        email.delegate = self
        phoneNumber.delegate = self
        birthday.delegate = self
        startTerm.delegate = self
        showDatePicker()
    }
}



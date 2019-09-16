//
//  LogInViewController.swift
//  clydeClubIos
//
//  Created by Rahimi, Meena Nichole (Student) on 6/12/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore

class LogInViewController: UIViewController, UITextFieldDelegate{

    
    
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //Presents Sign up view
    @IBAction func GoToSignUp(_ sender: Any) {
        performSegue(withIdentifier: "SegueToSignUp", sender: self)
    }
    
    //Presents homepage
    // TO-DO: add a checker to see if the student was authenitcated, if we are not using salesforce community login
    @IBAction func LogIntoAccount(_ sender: UIButton) {
        performSegue(withIdentifier: "SegueToMain", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        password.delegate = self
    }
    
    
    // Changes the background color of the textfield when the user begins typing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // Changes the background color and text color of the textfield when the user finishes typing
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}

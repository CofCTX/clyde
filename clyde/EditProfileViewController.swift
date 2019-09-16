//
//  EditProfileViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 9/9/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import MobileCoreServices
import SalesforceSDKCore
import SmartSync
import SmartStore
import SwiftyJSON
import MapKit
import SearchTextField
import CoreLocation

/// Class for the Edit Profile View
class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RestClientDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // Variables
    var contactId = ""
    var profileImage: UIImage!
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "Edit Profile")
    var reach: Reachability?
    var internetConnection = false
    var studentStatus = true
    var userId = ""
    //Picker options
    var birthSexOptions = ["Female","Male"]
    var genderOptions = ["Female","Male","Other"]
    var studentTypeOptions = ["Freshman","Transfer"]
    var ethnicOptions = ["Alaskan Native", "American Indian", "Asian", "Black or African American", "Hispanic", "Mexican or Mexican American", "Middle Eastern", "Native Hawaiian", "Other", "Pacific Islander", "Prefer to not respond", "Puerto Rican", "Two or more races", "White"]
    
    let genderPicker = UIPickerView()
    let genderIdentityPicker = UIPickerView()
    let studentTypePicker = UIPickerView()
    let ethnicPicker = UIPickerView()
    
    // Outlet for the menu button
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    // Outlet for user's profile photo image view
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Outlets for the UI Textfields
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var highSchoolTextField: SearchTextField!
    
    @IBOutlet weak var graduationYearTextField: UITextField!
    @IBOutlet weak var ethnicOriginTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var genderIdentityTextField: UITextField!
    @IBOutlet weak var studentTypeTextField: UITextField!
    @IBOutlet weak var userName: UILabel!
    
    let defaults = UserDefaults.standard
    private var honorsCollegeInterestText = ""
    @IBOutlet weak var honorsSwitch: UISwitch!
    @IBAction func honorsAction(_ sender: UISwitch) {
        if sender.isOn == true{
            honorsCollegeInterestText = "1"
        }else{
            honorsCollegeInterestText = "0"
        }
    }
    
    private var mobileText = ""
    private var mobileOptInText = ""
    @IBOutlet weak var mobileSwitch: UISwitch!
    @IBAction func mobileAction(_ sender: UISwitch) {
        if sender.isOn == true{mobileOptInText = "1"}
        else{mobileOptInText = "0"}
    }
    
    
    // Boolean variable to determine whether a new picture was added.
    var newPic: Bool?
    
    // Creates a UITapGestureRecognizer to edit the user's image
    let tapRec = UITapGestureRecognizer()
    
    // Creates a date picker for the birthday field.
    let datePicker = UIDatePicker()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /// Determines whether there is a valid internet connection
    ///
    /// - Parameter notification: notification description
    func reachabilityChanged(notification: NSNotification) {
        if self.reach!.isReachableViaWiFi() || self.reach!.isReachableViaWWAN() {
            print("Service available!!!")
            self.internetConnection = true
        } else {
            print("No service available!!!")
            self.internetConnection = false
        }
    }
    
    /// Shows the date picker for the birthdate field when called.
    private func showDatePicker(){
        // Formats the date picker.
        datePicker.datePickerMode = .date
        
        // Creates the toolbar and the sizes it to fit.
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // Creates the various buttons.
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker));
        
        // Sets the buttons.
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        // Adds the datepicker and toolbar to the birthdate text field.
        birthDateTextField.inputAccessoryView = toolbar
        birthDateTextField.inputView = datePicker
    }
    
    /// Called when the user picks a date
    ///
    /// Formats the date correctly so that it will not cause an error once it is pushed into Salesforce
    @objc func doneDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        birthDateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    
    /// Method that determines actions after "save" button pressed
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if self.studentStatus == true{
            self.insertIntoSoup()
            //self.syncUp()
              self.updateSalesforceData()
            sender.backgroundColor = #colorLiteral(red: 0.7158062458, green: 0.1300250292, blue: 0.2185922265, alpha: 1)
        }else{
            sender.backgroundColor = #colorLiteral(red: 0.7158062458, green: 0.1300250292, blue: 0.2185922265, alpha: 1)
            let alert = UIAlertController(title: "Cannot Save Information", message: "Clyde Club is not allowed to edit your information at this time. Please contact (email goes here)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            self.present(alert, animated: true)        }
        
    }
    
    /// UIPickerView Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == genderIdentityPicker){
            return genderOptions.count
        }else if (pickerView == genderPicker){
            return birthSexOptions.count
        }else if (pickerView == ethnicPicker){
            return ethnicOptions.count
        }
        else{
            return studentTypeOptions.count
        }}
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == genderIdentityPicker){
            return genderOptions[row]
        } else if pickerView == genderPicker{
            return birthSexOptions[row]
        }else if pickerView == ethnicPicker{
            return ethnicOptions[row]
        }
        else{
            return studentTypeOptions[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.genderIdentityPicker{
            self.genderIdentityTextField.text = genderOptions[row]
        }else if pickerView == self.genderPicker{
            self.genderTextField.text = genderOptions[row]
        }else if pickerView == self.ethnicPicker{
            self.ethnicOriginTextField.text = ethnicOptions[row]
        }else{
            self.studentTypeTextField.text = studentTypeOptions[row]
        }
    }
    override func loadView() {
        super.loadView()
        //self.syncDown()
        self.loadFromStore()
        //self.loadFromStore()
    }
    
    
    
    /// Syncs the store to Salesforce
    func syncDown(){
        if let smartStore = self.store,
            let  syncMgr = SyncManager.sharedInstance(store: smartStore) {
            do {
                try syncMgr.reSync(named: "syncDownContact") { [weak self] syncState in
                    if syncState.isDone() {
                        self?.loadFromStore()
                        
                    }
                }
            } catch {
                print("Unexpected sync error: \(error).")
            }
        }    }
    
  
    
    func syncUp(){
        if let smartStore = self.store,
            let  syncMgr = SyncManager.sharedInstance(store: smartStore) {
            do {
                try syncMgr.reSync(named: "syncUpContact") {
                    syncState in
                    if  syncState.hasFailed(){
                        print("Sync failed")
                    }
                    if syncState.isDone() {
                        //                        let alert = UIAlertController(title: "Information Saved", message: "Clyde Club saved your information.", preferredStyle: .alert)
                        //
                        //                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        //
                        //                        self?.present(alert, animated: true)
                        print("Sync Done")
                    }
                }
            } catch {
                print("-----------------Unexpected sync error------------------\(error).")
            }
        }     }
    
    /// Presents view
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataArray = loadSchoolsFromStore()
//        let profilePhotoString = defaults.string(forKey: "ProfilePhotoURL")
//        let url = URL(string: profilePhotoString!)!
//        
//        let task = URLSession.shared.dataTask(with: url){ data,response, error in
//            guard let data = data, error == nil else {return}
//            DispatchQueue.main.async {
//                self.profileImageView.image = UIImage(data:data)
//                
//            }
//        }
//        task.resume()        //  self.pushImage()
        // Sets the image style
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true;
        self.profileImageView.layer.borderWidth = 3
        self.profileImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.profileImageView.layer.cornerRadius = 10
        
        // Adds tap gesture to the profileImageView
        tapRec.addTarget(self, action: #selector(tappedView))
        profileImageView.addGestureRecognizer(tapRec)
        
        // Delegates
        addressTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipTextField.delegate = self
        birthDateTextField.delegate = self
        emailTextField.delegate = self
        highSchoolTextField.delegate = self
        graduationYearTextField.delegate = self
        ethnicOriginTextField.delegate = self
        mobileTextField.delegate = self
        genderIdentityTextField.delegate = self
        genderTextField.delegate = self
        studentTypeTextField.delegate = self
        
        let schoolid = getSchoolId(name: "Shelterwood School")
        print(schoolid)
        print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
        
        // Calls showDatePicker
        showDatePicker()
        menuBar(menuBarItem: menuBarButton)
        addLogoToNav()
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // Gender and Gender Identity pickers
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(cancelPicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton, doneButton], animated: false)
        
        genderTextField.inputAccessoryView = toolbar
        
        genderTextField.inputView = genderPicker
        genderPicker.delegate = self
        
        genderIdentityTextField.inputAccessoryView = toolbar
        genderIdentityTextField.inputView = genderIdentityPicker
        genderIdentityPicker.delegate = self
        
        
        studentTypeTextField.inputAccessoryView = toolbar
        studentTypeTextField.inputView = studentTypePicker
        studentTypePicker.delegate = self
        
        ethnicOriginTextField.inputAccessoryView = toolbar
        ethnicOriginTextField.inputView = ethnicPicker
        ethnicPicker.delegate = self
        
        highSchoolTextField.startVisibleWithoutInteraction = false
        highSchoolTextField.filterStrings(dataArray)
        highSchoolTextField.theme.font = UIFont(name: "Adobe Caslon Pro", size: 14.0)!
        highSchoolTextField.theme.bgColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        mobileTextField.inputAccessoryView = toolbar
        graduationYearTextField.inputAccessoryView = toolbar
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        
        if  let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {User:Id} from {User}", pageSize: 1),
            let smartStore = self.store,
            let record = try? smartStore.query(using: querySpec, startingFromPageIndex: 0) as? [[String]]{
            let id = record[0][0]
            DispatchQueue.main.async{
                print(id)
                self.userId = id
            }
            
        }}
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        scrollView.contentOffset = CGPoint(x:0, y:keyboardFrame.size.height/2)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.contentOffset = .zero
    }
    
    
    
    

    func getSchoolId(name: String) -> String{
        var schoolId = ""
        let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {School:Id} from {School} where {School:Name} == '\(String(describing: name))'", pageSize: 10000)
        
        do{
            let records = try self.store?.query(using: querySpec!, startingFromPageIndex: 0)
            guard let record = records as? [[String]] else {
                os_log("\nBad data returned from SmartStore query.", log: self.mylog, type: .debug)
                return schoolId
            }
            print(record)
            let id = (record[0][0])
            schoolId = id
        }//do
        catch let e as Error?{
            print(e as Any)
        }
        return schoolId
    }//function    }
    
    
    func loadSchoolsFromStore() -> Array<String>{
        var namesArray = ["name"]
        
        let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {School:Name},{School:Id} from {School}", pageSize: 10000)
        
        do{
            let records = try self.store?.query(using: querySpec!, startingFromPageIndex: 0)
            guard let record = records as? [[String]] else {
                os_log("\nBad data returned from SmartStore query.", log: self.mylog, type: .debug)
                return namesArray
            }
            let counter = record.count-1
            for i in 0...counter{
                let name  = record[i][0]
                print(name)
                namesArray.insert(name, at: i)
                
            }
            namesArray.sort()
            
        }//do
        catch let e as Error?{
            print(e as Any)
        }
        return namesArray
    }//function
    
    
    /// Loads data from store and presents on edit profile
    func loadFromStore(){
        let contactId = defaults.string(forKey: "ContactId")
        if  let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {Contact:Name},{Contact:MobilePhone},{Contact:MailingStreet},{Contact:MailingCity},{Contact:MailingState},{Contact:MailingPostalCode},{Contact:Gender_Identity__c},{Contact:Email},{Contact:Birthdate},{Contact:TargetX_SRMb__Gender__c},{Contact:TargetX_SRMb__Student_Type__c},{Contact:TargetX_SRMb__Graduation_Year__c},{Contact:Ethnicity_Non_Applicants__c},{Contact:Text_Message_Consent__c}, {Contact:Honors_College_Interest_Check__c},{Contact:Status_Category__c},{Contact:Id} from {Contact} where {Contact:Id} == '\(String(describing: contactId!))'", pageSize: 1),
            let smartStore = self.store,
            let record = try? smartStore.query(using: querySpec, startingFromPageIndex: 0) as? [[String]]{
            let name = (record[0][0])
            let phone = record[0][1]
            let address = record[0][2]
            let city = record[0][3]
            let state = record[0][4]
            let zip = record[0][5]
            let genderId = record[0][6]
            let email = record[0][7]
            let birthday = record[0][8]
            let birthsex = record[0][9]
            let studentType = record[0][10]
            let graduationYear = record[0][11]
            let ethnicity = record[0][12]
            let mobileOpt = record[0][13]
            let honors = record[0][14]
            let status = record[0][15]
            let id = record[0][16]
            DispatchQueue.main.async {
                self.userName.text = name
                self.userName.textColor = UIColor.black
                self.mobileTextField.text = phone
                self.addressTextField.text = address
                self.cityTextField.text = city
                self.stateTextField.text = state
                self.zipTextField.text = zip
                self.contactId = id
                self.emailTextField.text = email
                self.birthDateTextField.text = birthday
                self.genderIdentityTextField.text = genderId
                self.genderTextField.text = birthsex
                self.studentTypeTextField.text = studentType
                self.graduationYearTextField.text = graduationYear
                self.ethnicOriginTextField.text = ethnicity
                if mobileOpt == "0"{ self.mobileText = "Opt-out"
                    self.mobileOptInText = "0"
                    self.mobileSwitch.setOn(false, animated: true)
                }
                else{ self.mobileText = "Opt-in"
                    self.mobileSwitch.setOn(true, animated: true)
                    self.mobileOptInText = "1"
                }
                if honors == "0"{
                    self.honorsCollegeInterestText = "0"
                    self.honorsSwitch.setOn(false, animated: true)
                }else{ self.honorsCollegeInterestText = "1"
                    self.honorsSwitch.setOn(true, animated: true)
                }
                if status == "Prospect" || status == "Suspect"{
                    self.studentStatus = true
                }else{
                    self.studentStatus = false
                }
            }
        }    }
    
    
    
    
    /// Pulls data from the user form and upserts it into the "Contact" soup
    func insertIntoSoup(){
        let JSONData : [String:Any] = ["Name": self.userName.text!,
                                       "MobilePhone": self.mobileTextField.text!,
                                       "MailingStreet": self.addressTextField.text!,
                                       "MailingCity": self.cityTextField.text!,
                                       "MailingState": self.stateTextField.text!,
                                       "MailingPostalCode": self.zipTextField.text!,
                                       "Gender_Identity__c": self.genderIdentityTextField.text!,
                                       "Email": emailTextField.text!,
                                       "Birthdate": birthDateTextField.text!,
                                       "TargetX_SRMb__Gender__c": genderTextField.text!,
                                       "TargetX_SRMb__Student_Type__c": studentTypeTextField.text!,
                                       "TargetX_SRMb__Graduation_Year__c": graduationYearTextField.text!,
                                       "Ethnicity_Non_Applicants__c": ethnicOriginTextField.text!,
                                       "Text_Message_Consent__c": self.mobileOptInText,
                                       "Honors_College_Interest_Check__c": honorsCollegeInterestText,
                                       "__locally_deleted__": false,
                                       "__locally_updated__": true,
                                       "__locally_created__": false,
                                       "__local__": true,]
        
        if (((self.store?.soupExists(forName: "Contact"))!)){
            self.store?.clearSoup("Contact")
            self.store?.upsert(entries: [JSONData], forSoupNamed: "Contact")
            os_log("\n\nSmartStore loaded records for contact.", log: self.mylog, type: .debug)
        }
    }
    
    
    /// Sends data into Salesforce, this will need to be edited at some point
    private func updateSalesforceData(){
        
        // Creates a new record and stores appropriate fields.
        var record = [String: Any]()
        record["MailingStreet"] = self.addressTextField.text
        record["MailingCity"] = self.cityTextField.text
        record["MailingState"] = self.stateTextField.text
        record["MailingPostalCode"] = self.zipTextField.text
        record["TargetX_SRMb__Graduation_Year__c"] = self.graduationYearTextField.text
        record["Ethnicity_Non_Applicants__c"] = self.ethnicOriginTextField.text
        record["Email"] = self.emailTextField.text
        //record["AccountId"] = "001S00000105zkuIAA"
        record["Birthdate"] = self.birthDateTextField.text
        record["MobilePhone"] = self.mobileTextField.text
        record["TargetX_SRMb__Gender__c"] = self.genderTextField.text
        record["Gender_Identity__c"] = self.genderIdentityTextField.text
        record["TargetX_SRMb__Student_Type__c"] = self.studentTypeTextField.text
        // record["Honors_College_Interest_Check__c"] = self.honorsCollegeInterestText
        if self.mobileOptInText == "0"{
            record["Text_Message_Consent__c"] = "false"
        }else{
            record["Text_Message_Consent__c"] = "true"
            
        }
        //  record["Text_Message_Consent__c"] = self.mobileOptInText
        // NEED TO FIGURE OUT A WAY TO CONNECT THIS TO A USER NSOBJECT.
        // Creates a request for user information, sends it, saves the json into response, uses SWIFTYJSON to convert needed data (userAccountId)
        let userRequest = RestClient.shared.requestForUserInfo()
        RestClient.shared.send(request: userRequest, onFailure: { (error, urlResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking on user request: \(userRequest)")
        }) { [weak self] (response, urlResponse) in
            let userAccountJSON = JSON(response!)
            let userAccountID = userAccountJSON["user_id"].stringValue
            
            
            //Creates a request for the user's contact id, sends it, saves the json into response, uses SWIFTYJSON to convert needed data (contactAccountId)
            let contactIDRequest = RestClient.shared.request(forQuery: "SELECT ContactId FROM User WHERE Id = '\(userAccountID)'")
            RestClient.shared.send(request: contactIDRequest, onFailure: { (error, urlResponse) in
                SalesforceLogger.d(type(of:self!), message:"Error invoking on contact id request: \(contactIDRequest)")
            }) { [weak self] (response, urlResponse) in
                let contactAccountJSON = JSON(response!)
                let contactAccountID = contactAccountJSON["records"][0]["ContactId"].stringValue
                
                print("Creating update request")
                
                //Creates the update request.
                let updateRequest = RestClient.shared.requestForUpdate(withObjectType: "Contact", objectId: contactAccountID, fields: record)
                
                //Sends the update request
                RestClient.shared.send(request: updateRequest, onFailure: { (error, URLResponse) in
                    SalesforceLogger.d(type(of:self!), message:"Error invoking while sending upsert request: \(updateRequest), error: \(String(describing: error))")
                    //Creates a save alert to be presented whenever the user saves their information
                    let errorAlert = UIAlertController(title: "Error", message: "\(String(describing: error))", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self?.present(errorAlert, animated: true)
                }){(response, URLResponse) in
                    //Creates a save alert to be presented whenever the user saves their information
                    let saveAlert = UIAlertController(title: "Information Saved", message: "Your information has been saved.", preferredStyle: .alert)
                    saveAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self?.present(saveAlert, animated: true)
                    os_log("\nSuccessful response received")
                }
            }
        }
    }
    
    //    private func pushImage(){
    //        let photoRequest = RestClient.shared.request(forUploadFile: <#T##Data#>, name: <#T##String#>, description: <#T##String#>, mimeType: <#T##String#>)
    //        }
    
    
    
    
    
    
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
        textField.textColor = UIColor.black
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.isEnabled = self.studentStatus
        self.mobileSwitch.isEnabled = false
        self.honorsSwitch.isEnabled = self.studentStatus
        return self.studentStatus
    }
    
    
    
    /// Method that creates the camera and photo library action
    @objc func tappedView(){
        let alert = UIAlertController(title: "Select Image From", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = true
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = false
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    
    /// Method that creates the image picker controller.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as String) {
            self.profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            profileImageView.image = profileImage
            if newPic == true{
                UIImageWriteToSavedPhotosAlbum(profileImage, self, #selector(imageError), nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
        imageSaved()
    }
    
    func saveImage(){
        let imageData = self.profileImage.pngData()!
        let imageRequest = RestClient.shared.request(forUploadFile: imageData, name: "ProfileImage", description: "This is the user's profile picture.", mimeType: "image/png")
        RestClient.shared.send(request: imageRequest, onFailure: { (error, URLResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking while sending image request: \(imageRequest), error: \(String(describing: error))")
            //Creates a save alert to be presented whenever the user saves their information
            let errorAlert = UIAlertController(title: "Error", message: "\(String(describing: error))" , preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(errorAlert, animated: true)
        }){(response, URLResponse) in
            //Creates a save alert to be presented whenever the user saves their information
            let saveAlert = UIAlertController(title: "Image Saved", message: "Your information has been saved.", preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(saveAlert, animated: true)
            os_log("\nSuccessful response received")
            print(self.profileImage.jpegData(compressionQuality: 0.0)!)
        }}
    
    
    
    func imageSaved(){
        let imageData = self.profileImage.jpegData(compressionQuality: 0.1)!
        let base64 = imageData.base64EncodedString(options: .endLineWithLineFeed)
        
        let name = userName.text
        let data = [
            "Name": "user's pic",
            "Body": base64,
            "ParentId":"0035400000GV18bAAD"
        ]
        
        RestClient.shared.create("Attachment", fields: data, onFailure: { (error, urlResponse) in
            print(error!)
            
            let errorAlert = UIAlertController(title: "Error", message: "\(String(describing: error))", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(errorAlert, animated: true)
            
        }) { [weak self] (response, urlResponse) in
            print("yay!!")
            let saveAlert = UIAlertController(title: "Image Saved", message: "Your information has been saved.", preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self?.present(saveAlert, animated: true)
        }
        
        
        //        let documentRequest = RestClient.shared.requestForUpsert(withObjectType: "Document", externalIdField: "Id", externalId: nil, fields:JSONData)
        //        RestClient.shared.send(request: documentRequest, onFailure: { (error, urlResponse) in
        //            print(error)
        //            print("URLResponse\(documentRequest)")
        //            print(JSONData)
        //            let errorAlert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        //            errorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        //            self.present(errorAlert, animated: true)
        //            SalesforceLogger.d(type(of:self), message:"Error invoking on user request: \(documentRequest)")
        //        }) { [weak self] (response, urlResponse) in
        //            print("yay!!")
        //            let saveAlert = UIAlertController(title: "Image Saved", message: "Your information has been saved.", preferredStyle: .alert)
        //            saveAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        //            self?.present(saveAlert, animated: true)
        //        }
        
    }
    
    
    
    func pullImage(){
        
    }
    
    
    /// Error handler for the image picker
    @objc func imageError(image: UIImage, didFinishSavingwithError error: NSErrorPointer, contextInfo: UnsafeRawPointer){
        if error != nil{
            let alert = UIAlertController(title: "Image Save Failed", message: "Failed to save image", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

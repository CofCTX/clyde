//
//  CounselorViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 6/20/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore
import SwiftyJSON
import SmartSync
import MessageUI


/// Pulls the user's admission counselor from Salesforce and then presents the data on the view controller.
class CounselorViewController: UIViewController, MFMailComposeViewControllerDelegate {

    //-------------------------------------------------------------------------
    // MARK: Variables
    var name: String = ""
    var about: String = ""
    var email: String? = ""
    var id: String = ""
    var studentID: String = ""
    
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "profile")
    
    //------------------------------------------------------------------------
    // MARK: Outlets
    
    @IBOutlet var counselorView: UIView!
    @IBOutlet weak var counselorImage: UIImageView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var counselorName: UILabel!
    @IBOutlet weak var aboutMeText: UITextView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var counselorEmail: UIButton!
    @IBOutlet weak var phoneText: UIButton!
    

    //-------------------------------------------------------------------------
    // MARK: Action buttons
    
    /// When button is pressed, will take in the counselor's phone number, remove the - and (), and then calls the number.
    ///
    /// This will not work in the simulator.
    /// - Parameter sender: action button
    @IBAction func phone(_ sender: UIButton) {
        if  let phone = phoneText.titleLabel?.text{
            if let url = URL(string: "tel://\(phone.digitsOnly())"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            } else {
                print("This is not a valid number.")
            }
        }
    }
    
    
    /// When button is tapped, will email the counselor.
    ///This will not work in the simulator.
    /// - Parameter sender: action button
    @IBAction func email(_ sender: UIButton) {
        let email = self.email
            //Email "settings", these can be changed to anything.
            let subject = "Question Sent From Clyde Club"
            let body = "Hi! This is a test email from Clyde Club. Clyde Club is an app that is being developed by the Office of Admissions. If you have any questions, please contact rahimimn@cofc.edu."
            let to = [email]
            //Creates the mail view, allows user to write an email to the counselor.
            let mailView: MFMailComposeViewController = MFMailComposeViewController()
            mailView.mailComposeDelegate = self
            mailView.setSubject(subject)
            mailView.setMessageBody(body, isHTML: false)
        mailView.setToRecipients(to as? [String])
            
            self.present(mailView, animated: true, completion: nil)
    }
    

    /// Will present a view controller with the Office of Admissions
    /// Instagram Page after the button is tapped.
    ///
    /// - Parameter sender: action button
    @IBAction func instagram(_ sender: UIButton) {
        show("https://www.instagram.com/cofcadmissions/")    }
    
    
    //-----------------------------------------------------------------------
    // MARK: View functions
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDataFromStore()
        self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
    }
   
    
    //------------------------------------------------------------------------
    // MARK: Mail Compose Function
    
    
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
    
    
    
    //--------------------------------------------------------------------------
    // MARK: Salesforce Functions
    
    
    /// SmartStore related function that loads Counselor data from the 'Counselor' soup
    ///
    /// Loads Name, MobilePhone, AboutMe, Email, ImageUrl
    func loadDataFromStore(){
        // Loading Indicator is created, starts animated before user's information request is sent
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        loadingIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        loadingIndicator.center = counselorView.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        loadingIndicator.color = #colorLiteral(red: 0.6127323508, green: 0.229350239, blue: 0.2821176946, alpha: 1)
        counselorView.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        let querySpec = QuerySpec.buildSmartQuerySpec(smartSql: "select {Counselor:Name}, {Counselor:MobilePhone}, {Counselor:AboutMe},{Counselor:Email}, {Counselor:Image_Url__c} from {Counselor}", pageSize: 1)
        
        do{
            let records = try self.store?.query(using: querySpec!, startingFromPageIndex: 0)
            guard let record = records as? [[String]] else{
                os_log("\nBad data returned from SmartStore query.", log: self.mylog, type: .debug)
                return
            }
            
            let counselorName = record[0][0]
            let counselorPhone = record[0][1]
            let counselorAbout = record[0][2]
            let counselorEmail = record[0][3]
            let counserlorImage = record[0][4]
            DispatchQueue.main.async {
                self.aboutMeText.text = counselorAbout
                self.aboutLabel.backgroundColor = #colorLiteral(red: 0.8870992064, green: 0.8414486051, blue: 0.7297345996, alpha: 1)
                self.contactLabel.backgroundColor = #colorLiteral(red: 0.8870992064, green: 0.8414486051, blue: 0.7297345996, alpha: 1)
                self.name = counselorName
                self.counselorName.text = counselorName
                self.counselorEmail.setTitle("Email: \(counselorEmail)", for: .normal)
                self.phoneText.setTitle("Phone: \(counselorPhone)", for: .normal)
                self.contactLabel.text = "Contact Information"
                self.aboutLabel.text = "About"
                self.header.backgroundColor = #colorLiteral(red: 0.8870992064, green: 0.8414486051, blue: 0.7297345996, alpha: 1)
                self.instagramButton.setTitle("@cofcadmissions", for: .normal)
                self.instagramButton.backgroundColor = #colorLiteral(red: 0.558098033, green: 0.1014547695, blue: 0.1667655639, alpha: 0.6402504281)
              
                
                let url = URL(string: counserlorImage)!
                
                let task = URLSession.shared.dataTask(with: url){ data,response, error in
                    guard let data = data, error == nil else {return}
                    print(error)
                    DispatchQueue.main.async {
                        self.counselorImage.image = UIImage(data:data)
                        self.email = counselorEmail
                        loadingIndicator.stopAnimating()
                    }
                }
                task.resume()
                
            }
        }catch let e as Error?{
            print(e as Any)
        }
    }
    

    //----------------------------------------------------------------------
    // MARK: Helper Functions
    
    /// Displays the URL within Safari
    ///
    /// - Parameter url: the url to be displayed
    func show(_ url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
}

//
//  ProfileViewController.swift
//
//  Created by Rahimi, Meena Nichole (Student) on 6/20/19.
//

import UIKit
import MobileCoreServices
import SalesforceSDKCore
import SmartSync
import SmartStore
import SwiftyJSON
import MapKit

import CoreLocation


/// Class for the Profile view
class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITextViewDelegate{
   
    
    
   
    // Outlet for the menu button
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    // Outlet for distance between user and cofc
    @IBOutlet weak var distanceText: UILabel!
    
    // Outlet for user's profile picture image view
    @IBOutlet weak var profileImageView: UIImageView!
    
    // Outlets for "Your Information"
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var addressText: UITextView!
    @IBOutlet weak var birthdateText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var schoolText: UILabel!
    @IBOutlet weak var anticipatedStartText: UILabel!
    @IBOutlet weak var ethnicText: UILabel!
    @IBOutlet weak var genderText: UILabel!
    @IBOutlet weak var genderIdentityText: UILabel!
    @IBOutlet weak var mobileText: UILabel!
    @IBOutlet weak var studentTypeText: UILabel!
    @IBOutlet weak var honorsCollegeInterestText: UILabel!
    @IBOutlet weak var mobileOptInText: UILabel!
    
   //Creates the store variable
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "Profile")
    
    let defaults = UserDefaults.standard
    
    // Private variables for map
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    // Outlet for map view
    @IBOutlet weak var profileMap: MKMapView!
    
    // Private variables for id
     private var userId = ""
      var contactId = ""
    
    /// Sent to the view controller when the app recieves a memory warning. This is where variables can be taken out of memory to offload storage.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Creates the view that the viewController manages
    override func loadView() {
        super.loadView()
        self.loadDataFromStore()
        self.createMap()
        // Sets the image style
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true;
        self.profileImageView.layer.borderWidth = 3
        self.profileImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.profileImageView.layer.cornerRadius = 10
    }
    
    /// Notifies that the view controller is about to be added to memory
    override func viewWillAppear(_ animated: Bool) {
        self.createMap()

        
      }
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
        self.createMap()
//        let profilePhotoString = defaults.string(forKey: "ProfilePhotoURL")
//            let url = URL(string: profilePhotoString!)!
//
//            let task = URLSession.shared.dataTask(with: url){ data,response, error in
//                guard let data = data, error == nil else {return}
//                DispatchQueue.main.async {
//                    self.profileImageView.image = UIImage(data:data)
//
//                }
//            }
//            task.resume()
    }
    
    /// Updates the location constantly.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.currentLocation = locations.last as CLLocation?

    }

    
    
    /// Asks the delegate for a renderer object to use when drawing the specified overlay.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = #colorLiteral(red: 0.4470588235, green: 0.7803921569, blue: 0.9058823529, alpha: 1)
        return polylineRenderer
    }
    
    
    
    /// Loads the profile data from the SmartStore soup
    ///
    /// Displays Name, Mobile number, mailing address, birth sex and gender identity, student type, graduation year, ethnicity, message consent, and honors interest
    func loadDataFromStore(){
        let contactId = defaults.string(forKey: "ContactId")
        let querySpec = QuerySpec.buildSmartQuerySpec(

            smartSql: "select {Contact:Name},{Contact:MobilePhone},{Contact:MailingStreet},{Contact:MailingCity}, {Contact:MailingState},{Contact:MailingPostalCode},{Contact:Gender_Identity__c},{Contact:Email},{Contact:Birthdate},{Contact:TargetX_SRMb__Gender__c},{Contact:TargetX_SRMb__Student_Type__c},{Contact:TargetX_SRMb__Graduation_Year__c},{Contact:Ethnicity_Non_Applicants__c},{Contact:Text_Message_Consent__c}, {Contact:Honors_College_Interest_Check__c} from {Contact} where {Contact:Id} == '\(String(describing: contactId!))'",
            pageSize: 10)


        do {
            let records = try self.store?.query(using: querySpec!, startingFromPageIndex: 0)
            print(records!)
            guard let record = records as? [[String]] else {
                os_log("\nBad data returned from SmartStore query.", log: self.mylog, type: .debug)
                
                return
            }

            let name = (record[0][0])
            let phone = record[0][1]
            let address = record[0][2]
            let genderId = record[0][6]
            let email = record[0][7]
            let birthday = record[0][8]
            let birthsex = record[0][9]
            let studentType = record[0][10]
            let graduationYear = record[0][11]
            let ethnicity = record[0][12]
            let mobileOpt = record[0][13]
            let honors = record[0][14]

            DispatchQueue.main.async {
                self.userName.text = name
                self.userName.textColor = UIColor.black
                self.mobileText.text = phone
                self.addressText.text = address
                self.emailText.text = email
                self.birthdateText.text = birthday
                self.genderIdentityText.text = genderId
                self.genderText.text = birthsex
                self.studentTypeText.text = studentType
                self.anticipatedStartText.text = graduationYear
                self.ethnicText.text = ethnicity
                if mobileOpt == "0"{ self.mobileOptInText.text = "Opt-out"}
                else{ self.mobileOptInText.text = "Opt-in"}
                if honors == "1"{
                    self.honorsCollegeInterestText.text = "Yes"
                }else{ self.honorsCollegeInterestText.text = "No"}

            }
        } catch let e as Error? {
            print(e as Any)
            os_log("\n%{public}@", log: self.mylog, type: .debug, e!.localizedDescription)
        }

    }
    
   
    /// Adds the map to the view and calculates the distance between the user and College of Charleston
    func createMap(){
        // MAP
        profileMap.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        profileMap.showsUserLocation = false
        profileMap.layoutMargins = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
        
        
        guard let currentLocation = locationManager.location else{
            return
        }
        
        
        let cofcLocation = CLLocationCoordinate2D(latitude: 32.783830198, longitude: -79.936162922)
        let userLocation = CLLocationCoordinate2D(latitude: (currentLocation.coordinate.latitude), longitude: (currentLocation.coordinate.longitude))
        
        let currentPlacemark = MKPlacemark(coordinate: userLocation, addressDictionary: nil )
        let cofcPlacemark = MKPlacemark(coordinate: cofcLocation, addressDictionary: nil)
        
        
        let currentMapItem = MKMapItem(placemark: currentPlacemark)
        let cofcMapItem = MKMapItem(placemark: cofcPlacemark)
        
        let currentPointAnnotation = MKPointAnnotation()
        currentPointAnnotation.title = "Your Location"
        if let location = currentPlacemark.location {
            currentPointAnnotation.coordinate = location.coordinate
        }
        
        
        let cofcPointAnnotation = MKPointAnnotation()
        cofcPointAnnotation.title = "The College of Charleston: \nOffice of Admissions"
        
        if let location = cofcPlacemark.location {
            cofcPointAnnotation.coordinate = location.coordinate
        }
        self.profileMap.showAnnotations([currentPointAnnotation, cofcPointAnnotation], animated: true)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = currentMapItem
        directionsRequest.destination = cofcMapItem
        directionsRequest.transportType = .automobile
        
        let calculateDirections = MKDirections(request: directionsRequest)
        
        calculateDirections.calculate { [weak self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self?.profileMap.addOverlay(route.polyline)
                self?.profileMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        let cofcAddress = CLLocation(latitude: cofcLocation.latitude, longitude: cofcLocation.longitude)
        var distanceInMeters = currentLocation.distance(from:cofcAddress)
        let kilometersToMilesConversion = 1609.344
        distanceInMeters = distanceInMeters/kilometersToMilesConversion
        if distanceInMeters < 1 {
            self.distanceText.text = "\((String(format: "%.2f", distanceInMeters))) miles"
            
        }else{
        self.distanceText.text = "\((distanceInMeters).rounded().formatForProfile) miles"
        }
        
        
    }
    
    
    

   
}


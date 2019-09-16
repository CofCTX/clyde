//
//  CheckInViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 6/21/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore
import SwiftyJSON
import Foundation
import CoreLocation
import MapKit

class EventDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    //--------------------------------------------------------------------------
    // MARK: Variables
    
    var capturedEventId : String?
    var directions = ""
    var directionsCounter = 1
    var directionsArray: Array<Any> = []
    @IBOutlet weak var directionsLabel: UILabel!
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var map: MKMapView!
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var qrView: UIImageView!
    
   
    
    //---------------------------------------------------------------------
    // MARK: View Methods
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.loadView()
        self.pullAddress()
        
    }

    override func loadView() {
        super.loadView()
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
        
      
        
        let array = capturedEventId?.split(separator: " ")
        let id = array![1]
        
        
        // Picture method
        let imageUrl = "https://chart.googleapis.com/chart?chs=325x325&cht=qr&chl=https://cofc.tfaforms.net/217890?tfa_1="
        let url = imageUrl + id
           
        DispatchQueue.main.async {
                
                let url = URL(string: url)!
                let task = URLSession.shared.dataTask(with: url){ data,response, error in
                    guard let data = data, error == nil else {return}
                    DispatchQueue.main.async {
                        self.qrView.image = UIImage(data:data)
                       
                        
                    }
                }
                task.resume()
            }
            
        
    }
    
    //--------------------------------------------------------------------------
    // Action Buttons
    
    
    /// Action Button that performs a segue back to the orignial page
    @IBAction func backButton(_ sender: UIBarButtonItem) {}
    
    /// Action function for the right button, increases through the directions array.
    ///
    /// Simple logic.
    /// - Parameter sender: UIButton
    @IBAction func rightButton(_ sender: UIButton) {
        if directionsCounter + 1 <= directionsArray.count{
            self.directionsLabel.text = directionsArray[directionsCounter] as? String
              directionsCounter = directionsCounter + 1
        }
        else{
            self.directionsLabel.text = "You have arrived."
        }
    }//rightButton
    
    
    /// Action function for the left button, decreases through the directions array.
    ///
    /// Simple logic
    /// - Parameter sender: UIButton
    @IBAction func leftButton(_ sender: UIButton) {
        if directionsCounter == 1 {
            self.directionsLabel.text = directionsArray[directionsCounter] as? String
        }else{
            self.directionsLabel.text = directionsArray[directionsCounter] as? String
            directionsCounter = directionsCounter - 1
        }
    }//leftButton
    
    

    
    //---------------------------------------------------------------------
    // MARK: Salesforce Functions
    

    /// Salesforce function that pulls the address of an event directly from Salesforce
    func pullAddress(){
        
        // Takes the id that was captured on the Check-In page and splits it based on spaces
        let idSplit = capturedEventId?.split(separator: " ")
        let id = idSplit![1]
        // Creates the event id request and asks for the contact schedule item that is connected to the event and then sends it to Salesforce
        let eventIdRequest = RestClient.shared.request(forQuery: "SELECT TargetX_Eventsb__OrgEvent__c From TargetX_Eventsb__ContactScheduleItem__c WHERE Id = '\(id)'")
        RestClient.shared.send(request: eventIdRequest, onFailure: {(error, urlResponse) in
        }) { [weak self] (response, urlResponse) in
            guard let _ = self,
                let jsonResponse = response as? Dictionary<String, Any>,
                let _ = jsonResponse["records"] as? [Dictionary<String, Any>]
                else{
                    print("\nWeak or absent connection.")
                    return
            }
            let jsonContact = JSON(response!)
            let eventOrgId = jsonContact["records"][0]["TargetX_Eventsb__OrgEvent__c"].stringValue
            // Creates the address request and asks for the full address and time where/when the event is and then sends it to Salesforce.
            let addressRequest = RestClient.shared.request(forQuery: "SELECT Name, Event_City__c,Event_State__c,Event_Street__c,Event_Zip__c, TargetX_Eventsb__Start_Time_TZ_Adjusted__c  FROM TargetX_Eventsb__OrgEvent__c WHERE Id = '\(eventOrgId)'")
            RestClient.shared.send(request: addressRequest, onFailure: {(error, urlResponse) in
                
                print(error)
                
            }) { [weak self] (response, urlResponse) in
                guard let _ = self,
                    let jsonResponse = response as? Dictionary<String, Any>,
                    let _ = jsonResponse["records"] as? [Dictionary<String, Any>]
                    else{
                        print("\nWeak or absent connection.")
                        return
                }
                let jsonContact = JSON(response!)
                let name = jsonContact["records"][0]["Name"].stringValue
                let street = jsonContact["records"][0]["Event_Street__c"].stringValue
                let city = jsonContact["records"][0]["Event_City__c"].stringValue
                let state = jsonContact["records"][0]["Event_State__c"].stringValue
                let zip = jsonContact["records"][0]["Event_Zip__c"].stringValue
                let date = jsonContact["records"][0]["TargetX_Eventsb__Start_Time_TZ_Adjusted__c"].stringValue
                DispatchQueue.main.async {
                    self!.details.text = "\(name.capitalized)\n\(date)\n\(street), \(city) \n\(state), \(zip)"
            }
                let address = "\(street), \(city), \(zip)"
                
                
                // Gets the coordinates of using the address and then creates the map based on those coordinates.
                self!.getCoordinate(addressString: address, completionHandler: { coordinate, error in
                    guard error == nil else {return}
                    //use the coordinate here
                    self?.createMap(coordinates: coordinate, name: name)
                })
            }
        }
    }//func
    
    
    // -------------------------------------------------------------------------
    // MARK: Map Functions
    
    
    // Tells the delegate that the new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.currentLocation = locations.last as CLLocation?
    }
    
    
    
    // Asks the delegate for a renderer object to use when drawing the specified overlay.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = #colorLiteral(red: 0.4470588235, green: 0.7803921569, blue: 0.9058823529, alpha: 1)
        return polylineRenderer
    }
    
    
    
    /// Displays a map and creates a route between the user's current location and the event.
    ///
    /// Populates an array with "walking" instructions
    ///
    /// - Parameters:
    ///   - coordinates: event coordinates
    ///   - name: event name
    func createMap(coordinates: CLLocationCoordinate2D, name: String){
        map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.showsUserLocation = false
        
        map.layoutMargins = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
        
        guard let currentLocation = locationManager.location else{
            return
        }
        
        
        let eventLocation = coordinates
        let userLocation = CLLocationCoordinate2D(latitude: (currentLocation.coordinate.latitude), longitude: (currentLocation.coordinate.longitude))
        
        let currentPlacemark = MKPlacemark(coordinate: userLocation, addressDictionary: nil )
        let eventPlacemark = MKPlacemark(coordinate: eventLocation, addressDictionary: nil)
        
        
        let currentMapItem = MKMapItem(placemark: currentPlacemark)
        let eventMapItem = MKMapItem(placemark: eventPlacemark)
        
        let currentPointAnnotation = MKPointAnnotation()
        currentPointAnnotation.title = "You are here!"
        if let location = currentPlacemark.location {
            currentPointAnnotation.coordinate = location.coordinate
        }
        
        
        let eventPointAnnotation = MKPointAnnotation()
        eventPointAnnotation.title = name.capitalized
        
        
        if let location = eventPlacemark.location {
            eventPointAnnotation.coordinate = location.coordinate
        }
        self.map.showAnnotations([currentPointAnnotation, eventPointAnnotation], animated: true)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = currentMapItem
        directionsRequest.destination = eventMapItem
        directionsRequest.transportType = .walking
        
        let calculateDirections = MKDirections(request: directionsRequest)
        
        calculateDirections.calculate { [weak self] response, error in
            guard let unwrappedResponse = response else {
                print(error)
                return }
            
            for route in unwrappedResponse.routes {
                self?.map.addOverlay(route.polyline)
                self?.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                print("---------------------------------------------------")
                
                for step in route.steps {
                    self?.directionsArray.append(step.instructions)
                    print(self?.directionsArray)
                }
                self?.directionsLabel.text = "Your directions are ready!"
            }
        }
        
    }
    

    
    /// Getting a coordinate from an address string
    ///
    /// Pulled from the Apple Developer Documentation
    ///
    /// - Parameters:
    ///   - addressString: address
    ///   - completionHandler: handler
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        ///Initializes an interface for converting between geographic coordinates and place names
        let geocoder = CLGeocoder()
        
        // Submits a forward-geocoding request using the specified string and then determines the coordinates of address within the string
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }//getCoordinate
        
    
    
   // -------------------------------------------------------------------------
    
    
   
    }//class
    


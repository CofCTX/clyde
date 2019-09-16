//
//  CheckInTableViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 7/10/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore
import SmartSync

class CheckInTableViewController: UITableViewController {
    
    ///Events Dictionary
    var events : [Dictionary<String,Any>] = []
    ///User's contact Id is populated by User Defaults
    var contactId = ""
    ///Event Id
    var eventId: String!
    ///Contact Schedule Id that is linked to the Event
    var contactSchedId: String!
    
    ///Smart Store
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)!
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "Registered Events")
    
    ///Init User Defaults
    let defaults = UserDefaults.standard
    
    ///Outlet for the "hamburger" menu button
    @IBOutlet weak var menuBarButton: UIBarButtonItem!

    
    
    
    
    
    /// Init for the events list data source
    /// Displays the student's registered events on the table view.
    private let dataSource = EventsDataSource(cellReuseIdentifier: "sampleEvent") { record, cell in
        let eventName = record["Event_Name__c"] as? String ?? ""
         let eventId = record["Id"] as? String ?? ""
        cell.textLabel?.text = eventName.capitalized
        cell.detailTextLabel?.text = "Id: \(eventId)"
        
    }
    
    // Calld after the view controller is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        //Determines the height of each row
        tableView.rowHeight = 50
        // Indicated whether the controller will clear the selection when the table appears
        self.clearsSelectionOnViewWillAppear = false
        // Adds the menu bar
        self.menuBar(menuBarItem: menuBarButton)
        // Adds the cofc logo to the nav
        self.addLogoToNav()
        // Returns the contact id
        self.contactId = defaults.string(forKey: "ContactId")!
        
        // Sets the table data source
        self.dataSource.delegate = self as EventsDataSourceDelegate
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        // Inits a UIRefreshControl and adds the target
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self.dataSource, action: #selector(self.dataSource.fetchData), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl!)
        // Executes the soqlQuery
    
        
        self.dataSource.fetchData()
        _ = self.dataSource.returnEventName()
        
        
    }//viewDidLoad
    
    
    
    // -------------------------------------------------------------
    // MARK: Table View Functions
    
    
    //Returns the number of sections within the table.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //Returns the number of rows in a given section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
        
    }
    
    //Tells the tableview the specific row that is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the cell label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        //Pulls the eventId from the detail text label (this label is hidden on the actual view controller so that the user cannot see the id)
        eventId = currentCell.detailTextLabel?.text
        //Performs segue to view the details of the specific event in the selected row.
        performSegue(withIdentifier: "ViewEventDetails", sender: self)
    }
    
    /// Displays the table header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Creates a uiview
        let view = UIView()
        // Sets the background color of the uiview
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Image name
        let imageString = "Clyde-Campus-Tour.jpg"
        // Creates the image
        let image = UIImage(named: imageString)
        // Creates the image view
        let imageView = UIImageView(image: image!)
        // Creates the image frame
        imageView.frame = CGRect(x: 0, y: 0, width: 422, height: 150
        )
        // Sets the image transparency
        imageView.alpha = 0.75
        // Sets the image content mode
        imageView.contentMode = .scaleAspectFill
        // Places the imageView onto the uiView
        view.addSubview(imageView)
        // Creates a label
        let label = UILabel()
        // Adds text to the label
        label.text = "Your Registered Events"
        // Sets the label background color
        label.backgroundColor = #colorLiteral(red: 0.9546924233, green: 0.259139955, blue: 0.2854149044, alpha: 1)
        // Sets the label font
        label.font = UIFont(name: "Avenir Next Regular", size: 25.0)
        // Sets label text color and alignment
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.font = label.font.withSize(25)
        //
        label.frame = CGRect(x: 0, y: 142.67, width:414, height: 40)
        view.addSubview(label)
        
        return view
    }
    
    //Sets the header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180
    }

    //Notifies the view that a segue is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue identifier is ViewEventDetails, then set the destination and push the capturedEventId to the destination
        if (segue.identifier == "ViewEventDetails"){
            let detailsViewController = segue.destination as! EventDetailViewController
            detailsViewController.capturedEventId = eventId
        }
        
    }

}
    //-------------------------------------------------------------------------
    // Mark: Extension
    
extension CheckInTableViewController: EventsDataSourceDelegate {
    func EventsDataSourceDidUpdateRecords(_ dataSource: EventsDataSource) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}

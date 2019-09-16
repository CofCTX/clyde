//
//  EventsListTableViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 8/23/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore
import SmartSync

class EventsListTableViewController: UITableViewController {

    var contactId = ""
    var events : [Dictionary<String,Any>] = []
    var dataRows = [Dictionary<String, Any>]()
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)!
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "Registered Events")
    
    
    
    override func loadView() {
        super.loadView()
        self.title = "Your Registered Events"
       self.requestListOfRegisteredEvents()
        print(dataRows)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataRows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CellIdentifier"
        
        // Dequeue or create a cell of the appropriate type.
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        // If you want to add an image to your cell, here's how.
        let image = UIImage(named: "icon.png")
        cell.imageView?.image = image
        
        // Configure the cell to show the data.
        let obj = dataRows[indexPath.row]
        cell.textLabel?.text = obj["Name"] as? String
        
        // This adds the arrow to the right hand side.
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    
    
    private func requestListOfRegisteredEvents(){
        var id = self.getContactId()
        let request = RestClient.shared.request(forQuery: "SELECT TargetX_Eventsb__OrgEvent__c FROM TargetX_Eventsb__ContactScheduleItem__c WHERE TargetX_Eventsb__Contact__c = '\(id)'")
        RestClient.shared.send(request: request, onFailure: { (error, urlResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking: \(error)")
        }) { [weak self] (response, urlResponse) in
            
            guard let strongSelf = self,
                let jsonResponse = response as? Dictionary<String,Any>,
                let result = jsonResponse ["records"] as? [Dictionary<String,Any>]  else {
                    return
            }
            print(result)
            
            DispatchQueue.main.async {
                self!.events = result
                strongSelf.dataRows = result
            }
        }    }

    func getContactId() -> String{
        
        var id = ""
        let userQuery = QuerySpec.buildSmartQuerySpec(smartSql: "select {Contact:Id} from {Contact}", pageSize: 1)
        do{
            let records = try self.store.query(using: userQuery!, startingFromPageIndex: 0)
            guard let record = records as? [[String]] else{
                os_log("\nBad data returned from SmartStore query.", log: self.mylog, type: .debug)
                print(records)
                return "no"
            }
            
            id = record[0][0] as! String
            print("This is the contactId within the request \(id)")
            return id
            
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.contactId = id
                    
                }
            }
            
        }catch let e as Error?{
            print(e as Any)
        }
        return id
    }
}

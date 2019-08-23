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
    var events : [Dictionary<String,Any>] = []
    var contactId = ""
    var store = SmartStore.shared(withName: SmartStore.defaultStoreName)!
    let mylog = OSLog(subsystem: "edu.cofc.clyde", category: "Registered Events")
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
   
   
    
    
    
    private let dataSource = EventsDataSource(soqlQuery: "SELECT TargetX_Eventsb__OrgEvent__c FROM TargetX_Eventsb__ContactScheduleItem__c WHERE TargetX_Eventsb__Contact__c = '0035400000GV18bAAD'", cellReuseIdentifier: "sampleEvent") { record, cell in
        let eventName = record["TargetX_Eventsb__OrgEvent__c"] as? String ?? ""
       
        cell.textLabel?.text = eventName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 40
        self.clearsSelectionOnViewWillAppear = false
        self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
        self.contactId = getContactId()
        self.dataSource.delegate = self as! EventsDataSourceDelegate
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self.dataSource, action: #selector(self.dataSource.fetchData), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl!)
        self.dataSource.fetchData()
    }
    
    override func loadView() {
        super.loadView()
       
        self.requestListOfRegisteredEvents()
   
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
                
            }
        }    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    

    
    
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
extension CheckInTableViewController: EventsDataSourceDelegate {
    func EventsDataSourceDidUpdateRecords(_ dataSource: EventsDataSource) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}

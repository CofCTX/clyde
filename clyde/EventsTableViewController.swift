//
//  EventsTableViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 6/26/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {

    
    // TO-DO: pull the list of available events from salesforce, present the information within the tableView.
    // When user taps on an event, present a form that allows them to sign up for the event.
    // Request access to user's calendar, to add the event.
    
    
    
    
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.menuBar(menuBarItem: menuBarButton)
        self.addLogoToNav()
    }

    // MARK: - Table view data source
    
    
    //Returns the number of sections within a table.
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    //Returns the number of rows in the section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

   
}

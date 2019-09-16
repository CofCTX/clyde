//
//  SlideInTableViewController.swift
//  clydeClubIos
//
//  Created by Rahimi, Meena Nichole (Student) on 6/18/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//
import Foundation
import UIKit
import SafariServices
import SalesforceSDKCore

class SlideInTableViewController: UITableViewController{
   
    //-------------------------------------------------------------------------
    // MARK: Variables
    var window: UIWindow?

    //-------------------------------------------------------------------------
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //-------------------------------------------------------------------------
    // MARK: Table functions
    
    //Returns the number of sections.
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //Returns the number of rows in the section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 14
    }

    
    //Determines which cell was selected, and then presents the corresponding url.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlArray = ["https://www.cofc.edu/", "https://my.cofc.edu/cp/home/displaylogin","https://cofcharleston.force.com/portal/TX_SiteLogin?startURL=%2Fportal%2FTargetX_Base__Portal&_ga=2.125371468.736608744.1561053275-124322718.1558454919"]
        if indexPath.row == 9{
            UserAccountManager.shared.logout()
        }
        if indexPath.row == 11{
            show(urlArray[0])}
        if indexPath.row == 12{
            show(urlArray[1])
        }
        if indexPath.row == 13{
            show(urlArray[2])
        }
    }
    
    //-------------------------------------------------------------------------
    // MARK: Helper functions
    
    
    //Takes a url as a parameter, and then makes it appear with an internal safari page.
    func show(_ url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
   
}




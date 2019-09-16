//
//  CheckInListViewController.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 7/10/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import UIKit


/// Class for the CheckInListView
class CheckInListViewController: UIViewController{

  
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        //reveals menu
        if revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController().revealToggle(_:))
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class checkInTable: UITableView{
}

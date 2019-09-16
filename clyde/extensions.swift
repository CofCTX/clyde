//
//  extensions.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 7/12/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import SafariServices


// MARK: - Double extesion
extension Double {
    /// Removes the remainder from Double
    var formatForProfile: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }}

// MARK: - UIViewController extension
extension UIViewController{
    /// Adds the menu bar controller to the revealViewController
    ///
    /// - Parameter menuBarItem: the bar item that controlls the menu reveal.
    func menuBar(menuBarItem: UIBarButtonItem){
        if revealViewController() != nil {
            menuBarItem.target = self.revealViewController()
            menuBarItem.action = #selector(SWRevealViewController().revealToggle(_:))
            self.revealViewController()?.rearViewRevealWidth = 350
            
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }
    
     var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Adds the cofc logo to the views
    func addLogoToNav(){
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds =  false
        let logo = UIImage(named: "whiteLogo.png")
        imageView.image = logo
        self.navigationItem.titleView = imageView

    }
}

// MARK: - String extension
extension String{
    
    /// Removes all non-digit characters
    ///
    /// - Returns: A string of digits
    func digitsOnly() -> String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}




//
//  PopUp.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 8/5/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation

class InfoAlert{
    
    private var alertWindow: UIWindow
    static var shared = InfoAlert()
    
    init(){
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.isHidden = true
    }
    
    private func show(completion: @escaping ((Bool) -> Void)){
        let controller = UIAlertController(
            title: "W)
    }
    
    
    
    
}

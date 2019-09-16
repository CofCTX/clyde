//
//  UIView.swift
//  CofCApp
//
//  Created by Rahimi, Meena Nichole (Student) on 6/7/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import UIKit



//NOT CURRENTLY IN USE
private var ActivityIndicatorViewAssociateKey = "ActivityIndicatorViewAssociateKey"

extension UIView{
    var activityIndicatorView: UIActivityIndicatorView{
        get{
            if let activityIndicatorView = objc_getAssociatedObject(self, &ActivityIndicatorViewAssociateKey) as? UIActivityIndicatorView{
                return activityIndicatorView
            }else {
                let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                activityIndicatorView.style = .whiteLarge
                activityIndicatorView.color = .gray
                activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2) //center
                activityIndicatorView.hidesWhenStopped = true
                addSubview(activityIndicatorView)
                
                objc_setAssociatedObject(self, &ActivityIndicatorViewAssociateKey, activityIndicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return activityIndicatorView
            }
        } set{
            addSubview(newValue)
            objc_setAssociatedObject(self, &ActivityIndicatorViewAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

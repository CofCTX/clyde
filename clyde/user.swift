//
//  user.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 7/1/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore

struct User : Decodable{
    var id: String
    var name: String
    var counselor: Counselor?
    var streetAddress: String
    var city: String
    var state: String
    var zipCode: String
    var phone: String
    var email: String
    var gender: String
    var honorsCollegeInterest: Bool
    var mobileOpt: Bool
    var genderId: String
    var ethnicity: String
    var studentType: String
    var graduationYear: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case counselor = "Counselor"
        case streetAddress = "MailingStreet"
        case city = "MailingCity"
        case state = "MailingState"
        case zipCode = "MailingPostalCode"
        case phone = "Phone"
        case email = "Email"
        case gender = "TargetX_SRMb__Gender__c"
        case honorsCollegeInterest = "Honors_College_Interest_Check__c"
        case mobileOpt = "Text_Message_Consent__c"
        case genderId = "Gender_Identity__c"
        case ethnicity = "Ethnicity_Non_Applicants__c"
        case studentType = "TargetX_SRMb__Student_Type__c"
        case graduationYear = "TargetX_SRMb__Graduation_Year__c"
        
    }

}

struct Counselor : Decodable{
    var id: String
    var name: String
    var about: String
    var phone: String
    var email: String
    var imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case about = "AboutMe"
        case phone = "Phone"
        case email = "Email"
        case imageURL = "image_url__c"
    }
    
}

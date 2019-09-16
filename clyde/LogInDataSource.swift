//
//  LogInDataSource.swift
//  clydeClubIos
//
//  Created by Rahimi, Meena Nichole (Student) on 6/13/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore

protocol LogInDataSourceDelegate: AnyObject {
    

    /// - Parameter dataSource: The data source that was updated.
    func LogInDataSourceDidUpdateRecords(_ dataSource: LogInDataSource)
    
}

//THIS IS NOT CURRENTLY BEING USED.
class LogInDataSource: NSObject {
    
    let soqlQuery: String
    typealias salesForceRecord = [String : Any]
    private(set) var records: [salesForceRecord] = []
    weak var delegate: LogInDataSourceDelegate?
    
    init(soqlQuery: String){
        self.soqlQuery = soqlQuery
        super.init()
    }
    
    private func handleError(_ error: Error?, urlResponse: URLResponse? = nil) {
        let errorDescription: String
        if let error = error {
            errorDescription = "\(error)"
        } else {
            errorDescription = "An unknown error occurred."
        }
        SalesforceLogger.e(type(of: self), message: "Failed to successfully complete the REST request. \(errorDescription)")
    }
    
    
    @objc func fetchData(){
        guard !soqlQuery.isEmpty else { return }
        let request = RestClient.shared.request(forQuery: soqlQuery)
        RestClient.shared.send(request: request, onFailure: handleError) { [weak self] response, _ in
            guard let self = self else { return }
            var resultsToReturn = [salesForceRecord]()
            if let dictionaryResponse = response as? [String: Any],
                let records = dictionaryResponse["records"] as? [salesForceRecord] {
                resultsToReturn = records
            }
            DispatchQueue.main.async {
                self.records = resultsToReturn
                self.delegate?.LogInDataSourceDidUpdateRecords(self)
            }
        }
    }
    
    
}

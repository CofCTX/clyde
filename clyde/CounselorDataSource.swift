//
//  CounselorDataSource.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 6/20/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore

protocol CounselorDataSourceDelegate: AnyObject{
    func counselorDataSourceDidUpdateRecords(_ dataSource: CounselorDataSource)
}

//NOT IN USE
class CounselorDataSource: NSObject{
    typealias salesforceRecord = [String: Any]
    
    let soqlQuery: String
    private(set) var records: [salesforceRecord] = []
    weak var delegate: CounselorDataSourceDelegate?

    
    
    init(soqlQuery: String) {
        self.soqlQuery = soqlQuery
        super.init()
    }
    
    //Logs error
    private func handleError(_ error: Error?, urlResponse: URLResponse? = nil) {
        let errorDescription: String
        if let error = error {
            errorDescription = "\(error)"
        } else {
            errorDescription = "An unknown error occurred."
        }
        SalesforceLogger.e(type(of: self), message: "Failed to successfully complete the REST request. \(errorDescription)")
    }
    
    //Executes the "soqlQuery"
    @objc func fetchData() {
        guard !soqlQuery.isEmpty else { return }
        let request = RestClient.shared.request(forQuery: soqlQuery)
        RestClient.shared.send(request: request, onFailure: handleError) { [weak self] response, _ in
            guard let self = self else { return }
            var resultsToReturn = [salesforceRecord]()
            if let dictionaryResponse = response as? [String: Any],
                let records = dictionaryResponse["records"] as? [salesforceRecord] {
                resultsToReturn = records
            }
            DispatchQueue.main.async {
                self.records = resultsToReturn
                self.delegate?.counselorDataSourceDidUpdateRecords(self)
            }
        }
    }
    
}

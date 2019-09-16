//
//  EventsDataSource.swift
//  clyde
//
//  Created by Rahimi, Meena Nichole (Student) on 8/23/19.
//  Adapted from a Salesforce Mobile SDK tutorial
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore

/// Protocol adopted by classes that wish to be informed when an `EventsDataSource`
/// instance is updated.
protocol EventsDataSourceDelegate: AnyObject {
    
    /// Called when an object list data source has updated the value of its `records` property.
    ///
    /// - Parameter dataSource: The data source that was updated.
    func EventsDataSourceDidUpdateRecords(_ dataSource: EventsDataSource)
}

/// Supplies data to a `UITableView` for a list of events returned by a SOQL query.
/// An instance of this class can be used as a table view's `dataSource`.
class EventsDataSource: NSObject {
    let defaults = UserDefaults.standard

    /// A dictionary with string keys.
    typealias SFRecord = [String: Any]
    
    /// A closure that configures a given table view cell using the given
    /// dictionary of values retrieved from the Salesforce server.
    typealias CellConfigurator = (SFRecord, UITableViewCell) -> Void
    
    /// The query to be executed when `fetchData()` is called.
    let soqlQuery: String
    
    /// The reuse identifier to use for dequeueing cells from the table view.
    let cellReuseIdentifier: String
    
    /// The closure to call for each cell being provided by the data source.
    /// This will be called for each record in the list as it is displayed.
    let cellConfigurator: CellConfigurator
    
    /// The records returned from the Salesforce server.
    /// Each record is a dictionary containing the fields requested in the query.
    private(set) var records: [SFRecord] = []
    
    /// The delegate to notify when the list of records is updated.
    weak var delegate: EventsDataSourceDelegate?
    
    /// Initializes a data source with a SOQL query to execute.
    ///
    /// - Parameters:
    ///   - soqlQuery: The query to be executed when `fetchData()` is called.
    ///   - cellReuseIdentifier: The reuse identifier to use for dequeueing cells
    ///     from the table view.
    ///   - cellConfigurator: The closure to call for each cell being provided
    ///     by the data source.
    init(cellReuseIdentifier: String, cellConfigurator: @escaping CellConfigurator) {
       
        let contactId = defaults.string(forKey: "ContactId")
        self.soqlQuery = "SELECT TargetX_Eventsb__OrgEvent__c, Id, Event_Name__c FROM TargetX_Eventsb__ContactScheduleItem__c WHERE TargetX_Eventsb__Contact__c = '\(contactId ?? "")'"
        self.cellReuseIdentifier = cellReuseIdentifier
        self.cellConfigurator = cellConfigurator
        super.init()
    }
    
    /// Logs the given error.
    ///
    /// This Project doesn't do any sophisticated error checking, and simply
    /// uses this as the failure handler for `RestClient` requests. In a real-world
    /// application, be sure to replace this with information presented to the user
    /// that can be acted on.
    ///
    /// - Parameters:
    ///   - error: The error to be logged.
    ///   - urlResponse: Ignored; this argument provides compatibility with
    ///     the `SFRestFailBlock` API.
    private func handleError(_ error: Error?, urlResponse: URLResponse? = nil) {
        let errorDescription: String
        if let error = error {
            errorDescription = "\(error)"
        } else {
            errorDescription = "An unknown error occurred."
        }
        
        SalesforceLogger.e(type(of: self), message: "Failed to successfully complete the REST request. \(errorDescription)")
        DispatchQueue.main.async{
        }
    }
    
    /// Executes the `soqlQuery`.
    ///
    /// When it successfully completes, the `records` property is set to the
    /// results, and the delegate is notified of the update.
    @objc func fetchData(){
        guard !soqlQuery.isEmpty else { return }
        let request = RestClient.shared.request(forQuery: soqlQuery)
        RestClient.shared.send(request: request, onFailure: handleError) { [weak self] response, _ in
            guard let self = self else { return }
            var resultsToReturn = [SFRecord]()
            if let dictionaryResponse = response as? [String: Any],
                let records = dictionaryResponse["records"] as? [SFRecord] {
                resultsToReturn = records
            }
            DispatchQueue.main.async {
                self.records = resultsToReturn
                print(self.records)
                self.delegate?.EventsDataSourceDidUpdateRecords(self)
            }
        }
    }
    
    @objc func returnEventName() -> String{

       let eventId = "hi"
        return eventId}
}

extension EventsDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cellConfigurator(records[indexPath.row], cell)
        return cell
    }
}

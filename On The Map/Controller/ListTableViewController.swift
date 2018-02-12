//
//  ListTableViewController.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/10/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // MARK: Properties
    
    let reuseIdentifier = "listCell"
    let dupPinMsg = "You have already posted a student location. Would you like to overwrite this location?"
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLocations()
    }
    
    // MARK: IBActions
    
    @IBAction func addPin(_ sender: Any) {
        if ParseClient.sharedInstance().userAlreadyPostedAPin() {
            let alert = UIAlertController(title: "Duplicate Pin", message: dupPinMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .`default`, handler: { (action) in
                self.performSegue(withIdentifier: "listToAddPin", sender: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "listToAddPin", sender: self)
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        updateLocations()
    }
    
    // MARK: Helper Function
    
    func updateLocations() {
        ParseClient.sharedInstance().getLocations { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            } else {
                print(errorString!)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ParseClient.sharedInstance().students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListTableViewCell
        let sharedParseClient = ParseClient.sharedInstance()
        
        cell.nameLabel.text = sharedParseClient.students[indexPath.row].title
        cell.mapStringLabel.text = sharedParseClient.students[indexPath.row].mapString
        cell.mediaLinkLabel.text = sharedParseClient.students[indexPath.row].subtitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: ParseClient.sharedInstance().students[indexPath.row].subtitle!), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            let alert = UIAlertController(title: "Invalid URL", message: "This student's media URL is invalid.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
}

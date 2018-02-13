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
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            UdacityClient.sharedInstance().deleteSession(completionHandler: { (success, errorString) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(errorString!)
                    self.showAlert(title: "Logout Failed", message: "You were unable to logout.")
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
    
    // MARK: Helper Functions
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateLocations() {
        ParseClient.sharedInstance().getLocations { (success, errorTitle, errorDescription) in
            performUIUpdatesOnMain {
                if success || errorTitle == "Warning" {
                    self.tableView.reloadData()
                }
                if success == false {
                    self.showAlert(title: errorTitle!, message: errorDescription!)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedStudentData.sharedInstance().students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ListTableViewCell
        let student = SharedStudentData.sharedInstance().students[indexPath.row]
        
        cell.nameLabel.text = student.title
        cell.mapStringLabel.text = student.mapString
        cell.mediaLinkLabel.text = student.subtitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let urlString = SharedStudentData.sharedInstance().students[indexPath.row].subtitle!
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            showAlert(title: "Invalid URL", message: "This student's media URL is invalid.")
        }
    }
    
}

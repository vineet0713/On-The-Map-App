//
//  LoginViewController.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/10/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    let isSmallScreen = (UIScreen.main.bounds.height == CGFloat(568))
    let offlineMessage = "The Internet connection appears to be offline."
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isSmallScreen {
            subscribeToKeyboardNotifications()
        } else {
            usernameField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isSmallScreen {
            unsubscribeFromKeyboardNotifications()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // after logout, clear both username and password fields
        self.usernameField.text = ""
        self.passwordField.text = ""
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: Login
    
    @IBAction func login(_ sender: Any) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        self.view.frame.origin.y = 0
        
        if (usernameField.text?.isEmpty)! || (passwordField.text?.isEmpty)! {
            let alert = UIAlertController(title: "Empty Login Field", message: "Please enter your username and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.usernameField.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            UdacityClient.sharedInstance().authenticateWith(usernameField.text!, passwordField.text!, authCompletionHandler: { (success, errorString) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        print(errorString!)
                        if errorString! == self.offlineMessage {
                            self.showAlert(title: "No Connection", message: self.offlineMessage)
                        } else {
                            self.showAlert(title: "Invalid Login", message: "The username and/or password you entered was incorrect.")
                        }
                    }
                }
            })
        }
    }
    
    // MARK: Helper Functions
    
    func completeLogin() {
        UdacityClient.sharedInstance().loadUserData { (success, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.performSegue(withIdentifier: "loginComplete", sender: self)
                } else {
                    print(errorString!)
                    self.showAlert(title: "Could Not Get User Data", message: errorString!)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: Keyboard Notification functions

extension LoginViewController {
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if self.view.frame.origin.y == 0 {
            // moves the View up by a constant (so the keyboard won't cover up the content!)
            self.view.frame.origin.y -= 35
        }
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
}

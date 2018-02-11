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
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: Login
    
    @IBAction func login(_ sender: Any) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        self.view.frame.origin.y = 0
        
        if (usernameField.text?.isEmpty)! || (passwordField.text?.isEmpty)! {
            let alert = UIAlertController(title: "Empty Username or Password", message: "Please enter your username and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.usernameField.becomeFirstResponder()
                NSLog("The \"Empty Username or Password\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            
        }
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

//
//  SignUpVC.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/15/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit
import PKHUD
import FirebaseAuth

class SignUpVC: UIViewController {

    @IBOutlet weak var emailField: UnderlinedTextField!
    @IBOutlet weak var passwordField: UnderlinedTextField!
    @IBOutlet weak var repeatedPasswordField: UnderlinedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupValidators()
    }
    
    func setupValidators() {
        emailField.validator = EmailValidator()
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        let isValid = emailField.validate() && passwordField.validate()
        
        guard isValid, let login = emailField.text,
            let password = passwordField.text,
            let repeatedPassword = repeatedPasswordField.text
        else { return }
        
        guard password == repeatedPassword else {
            repeatedPasswordField.errorMessage = "Passwords don't match"
            return
        }
        
        Auth.auth().createUser(withEmail: login, password: password) { user, error in
            if let error = error {
                HUD.flash(.label(error.localizedDescription), delay: 2.0)
                return
            }

            Auth.auth().signIn(withEmail: login, password: password)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegueToReturnBack()
    }

}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            repeatedPasswordField.becomeFirstResponder()
        } else {
            signUpButtonPressed(textField)
        }
        
        return true
    }
}

//
//  SignInVC.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/15/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit
import FirebaseAuth
import PKHUD

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: UnderlinedTextField!
    @IBOutlet weak var passwordField: UnderlinedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribe()
        setupValidators()
    }
    
    func setupValidators() {
        emailField.validator = EmailValidator()
    }
    
    func subscribe() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            guard user != nil else { return }
            self.handleAuth()
        }
    }
    
    func handleAuth() {
        let vc = MapVC.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        let isValid = emailField.validate() && passwordField.validate()
        
        guard isValid, let login = emailField.text,
            let password = passwordField.text
        else { return }
        
        Auth.auth().signIn(withEmail: login, password: password) { user, error in
            guard user == nil else { return }
            HUD.flash(.label("Invalid credentials"), delay: 2)
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let vc = SignUpVC.instantiate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SignInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            signInButtonPressed(textField)
        }
        
        return true
    }
}

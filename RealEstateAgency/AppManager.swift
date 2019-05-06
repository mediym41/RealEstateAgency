//
//  AppManager.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/22/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AppManager {
    
    var window: UIWindow?
    
    static let shared = AppManager()
    
    private init() { }
    
    func start(window: UIWindow?) {
        self.window = window
        
        setupFirebase()
        showFirstScreen()
    }
    
    private func showFirstScreen() {
        //try? Auth.auth().signOut()
        let isAuthentificated = Auth.auth().currentUser != nil
        let rootVC = isAuthentificated ? MapVC.instantiate() : SignInVC.instantiate()
        let navigationController = UINavigationController(rootViewController: rootVC)
        
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    
    private func setupFirebase() {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.isPersistenceEnabled = true
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }

}

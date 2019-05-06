//
//  DetailedVC.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/21/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import PKHUD

class DetailedVC: UIViewController {

    @IBOutlet weak var houseImageView: UIImageView!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var buyTypeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var squareLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomsLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var property: Property?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupFunctional()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func setup() {
        guard let property = property else { return }
        
        setupImage(for: houseImageView, with: property.id)
        streetLabel.text = property.street
        typeLabel.text = property.type.rawValue.capitalized
        buyTypeLabel.text = property.buyType.rawValue.capitalized
        costLabel.text = "$ \(property.cost)"
        squareLabel.text = String(property.square)
        floorLabel.text = String(property.floor)
        roomsLabel.text = String(property.rooms)
        regionLabel.text = property.region.capitalized
        dateLabel.text = property.date.formatted(format: "dd.MM.yyyy")
    }
    
    func setupFunctional() {
        let isAdmin = Auth.auth().currentUser?.email == property?.sellerEmail
        guard isAdmin else { return }
        submitButton.setTitle("Remove", for: .normal)
        submitButton.setTitleColor(#colorLiteral(red: 0.5085785985, green: 0.03059747256, blue: 0.02396240644, alpha: 1), for: .normal)
        submitButton.backgroundColor = #colorLiteral(red: 0.8592880368, green: 0, blue: 0, alpha: 0.4084974315)
    }
    
    func setupImage(for imageView: UIImageView, with key: String) {
        let cache = ImageCache.default
        
        cache.retrieveImage(forKey: key) { result in
            switch result {
            case .success(let value):
                if value.cacheType == .none {
                    self.loadImage(for: imageView, with: key)
                } else {
                    DispatchQueue.main.async {
                        imageView.image = value.image
                    }
                }
                
            case .failure(let error):
                print("Kingfisher error: \(error)")
            }
        }
    }
    
    func loadImage(for imageView: UIImageView, with key: String) {
        let storageRef = Storage.storage().reference(withPath: "houses/")
        storageRef.child("\(key).jpg").downloadURL { url, err in
            guard let url = url else {
                print("Image Error: \(err?.localizedDescription ?? "Unknown")")
                imageView.image = #imageLiteral(resourceName: "NotFoundHouses")
                return
            }
            
            let resource = ImageResource(downloadURL: url, cacheKey: key)
            imageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "Placeholder"))
        }
    }
    
    func submit() {
        guard let email = Auth.auth().currentUser?.email,
            let property = property
            else {
                HUD.flash(.label("Failed"), delay: 2.0)
                return
        }
        
        let data: [String: Any] = ["email": email, "houseID": property.id]
        Firestore.firestore().collection("applications").addDocument(data: data)
        HUD.flash(.success, delay: 2.0)
        Analytics.logEvent("submit_house", parameters: [
            "id": property.id,
            "type": property.type,
            "buyType": property.buyType,
            "cost": property.cost,
            "square": property.square,
            "rooms": property.rooms,
            "floor": property.floor
        ])

    }
    
    func remove() {
        guard let property = property else { return }
        print(property.id)
        Firestore.firestore().collection("houses").document(property.id).delete { err in
            guard let err = err else { return }
            print(err)
        }
        Storage.storage().reference(withPath: "houses/\(property.id).jpg").delete() { err in
            guard let err = err else { return }
            print(err)
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let isAdmin = Auth.auth().currentUser?.email == property?.sellerEmail
        
        if isAdmin {
            remove()
        } else {
            submit()
        }
        
        performSegueToReturnBack()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegueToReturnBack()
    }

}

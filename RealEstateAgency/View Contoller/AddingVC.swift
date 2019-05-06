//
//  AddingVC.swift
//  RealEstateAgency
//
//  Created by Mediym on 5/5/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PKHUD

class AddingVC: UIViewController {
    
    @IBOutlet weak var estateImageView: UIImageView!
    @IBOutlet var typeButtons: [SelectableButton]!
    @IBOutlet var buyTypeButtons: [SelectableButton]!
    @IBOutlet weak var nicknameField: UnderlinedTextField!
    @IBOutlet weak var regionField: UnderlinedTextField!
    @IBOutlet weak var streetField: UnderlinedTextField!
    @IBOutlet weak var priceField: UnderlinedTextField!
    @IBOutlet weak var roomsField: UnderlinedTextField!
    @IBOutlet weak var squareField: UnderlinedTextField!
    @IBOutlet weak var floorField: UnderlinedTextField!
    
    var coords: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialState()
        setupValidators()
        setupImageViewPicker()
    }
    
    func setupImageViewPicker() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        estateImageView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupInitialState() {
        for i in 0..<typeButtons.count {
            let isSelected = i == 0
            typeButtons[i].setSelect(isSelected, animated: false)
        }
        
        for i in 0..<buyTypeButtons.count {
            let isSelected = i == 0
            buyTypeButtons[i].setSelect(isSelected, animated: false)
        }
    }
    
    func setupValidators() {
        priceField.validator = NumberValidator()
        roomsField.validator = NumberValidator()
        squareField.validator = NumberValidator()
        floorField.validator = NumberValidator()
    }
    
    @IBAction func typeButtonPressed(_ sender: UIButton) {
        let typeIndex = sender.tag
        let isSelect = typeButtons[typeIndex].isSelected
        
        for i in 0..<typeButtons.count {
            guard i != typeIndex else { continue }
            typeButtons[i].setSelect(isSelect, animated: true)
        }
    }
    
    @IBAction func buyTypeButtonPressed(_ sender: UIButton) {
        let typeIndex = sender.tag
        let isSelect = buyTypeButtons[typeIndex].isSelected
        
        for i in 0..<buyTypeButtons.count {
            guard i != typeIndex else { continue }
            buyTypeButtons[i].setSelect(isSelect, animated: true)
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let isValid = nicknameField.validate() && regionField.validate() &&
                      streetField.validate() && priceField.validate() &&
                      roomsField.validate() && squareField.validate() &&
                      floorField.validate()
        guard isValid, let nickname = nicknameField.text,
            let region = regionField.text?.lowercased(),
            let street = streetField.text,
            let price = priceField.text,
            let rooms = roomsField.text,
            let square = squareField.text,
            let floor = floorField.text,
            let coords = coords,
            let email = Auth.auth().currentUser?.email
        else { return }
        
        let type = typeButtons[0].isSelected ? "house" : "flat"
        let buyType = buyTypeButtons[0].isSelected ? "rent" : "sale"
        
        let data: [String: Any] = [
            "type": type,
            "buy_type": buyType,
            "cost": Int(price) as Any,
            "location": [
                "latitude": coords.latitude,
                "longitude": coords.longitude
            ],
            "region": region,
            "street": street,
            "square": Int(square) as Any,
            "floor": Int(floor) as Any,
            "rooms": Int(rooms) as Any,
            "seller_name": nickname,
            "seller_email": email,
            "date": Date()
        ]
        
        let document = Firestore.firestore().collection("houses").document()
        document.setData(data)
        if let image = estateImageView.image {
            upload(image: image, documentID: document.documentID)
        }
        
        HUD.flash(.label("Successful"), delay: 2.0)
        performSegueToReturnBack()
    }
    
    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true)
            } else {
                print("Camera is not available")
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { action in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    func upload(image: UIImage, documentID: String) {
        let storageRef = Storage.storage().reference(withPath: "houses/\(documentID).jpg")
        guard let data = image.jpegData(compressionQuality: 0.3) else {
            return
        }

        let uploadTask = storageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
        
    }
}

// MARK: - UIImagePickerControllerDelegate protocol
extension AddingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageAny = info[.originalImage], let image = imageAny as? UIImage {
            estateImageView.image = image
        }
        
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

//
//  TestVC.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/19/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit

class TransperentNavigationContoller: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

       navigationBar.setBackgroundImage(UIImage(), for: .default)
       navigationBar.shadowImage = UIImage()
       navigationBar.tintColor = #colorLiteral(red: 0.4772661328, green: 0.4104812145, blue: 0.2464975715, alpha: 1)
    }

}

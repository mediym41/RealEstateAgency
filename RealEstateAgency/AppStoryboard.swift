//
//  AppStoryboard.swift
//  MediumChat.ios
//
//  Created by Mediym on 3/7/19.
//  Copyright © 2019 Mediym. All rights reserved.
//

import UIKit

enum AppStoryboard: String {
    case main
    
    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue.capitalized, bundle: nil)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardID = viewControllerClass.name
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
}

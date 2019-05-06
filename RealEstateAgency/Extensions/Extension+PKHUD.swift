//
//  Extension+PKHUD.swift
//  MediumChat.ios
//
//  Created by Mediym on 3/13/19.
//  Copyright © 2019 Mediym. All rights reserved.
//

import PKHUD

extension HUD {
    static func flashPopup(with status: StatusViewPKHUD.Status, title: String, subtitle: String) {
        let contentView = StatusViewPKHUD(status: status, title: title, subtitle: subtitle)
        HUD.flash(.customView(view: contentView), delay: 2)
    }
}

//
//  MoneyPickerVC.swift
//  Kidcoin
//
//  Created by Mediym on 12/24/18.
//  Copyright © 2018 Mediym. All rights reserved.
//

import UIKit
import TTRangeSlider

protocol FilterCardVCDelegate: class {
    func filterChangedValue(item: PropertyFilterItem)
}

class FilterCardVC: CardVC {
    
    // MARK: - IBOutlets
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet var buyTypeButtons: [UIButton]!
    @IBOutlet weak var costSlider: TTRangeSlider!
    @IBOutlet weak var squareSlider: TTRangeSlider!
    @IBOutlet weak var roomsSlider: TTRangeSlider!
    @IBOutlet weak var floorSlider: TTRangeSlider!
    
    var filterItem = PropertyFilterItem()
    
    weak open var delegate: FilterCardVCDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFilterItem()
    }
    
    func updateFilterItem() {
        for button in typeButtons {
            let type = PropertyType(by: button.tag)
            if button.isSelected {
                filterItem.types.append(type)
            } else {
                filterItem.types = filterItem.types.filter { $0 != type }
            }
        }
        
        for button in buyTypeButtons {
            let type = BuyType(by: button.tag)
            if button.isSelected {
                filterItem.buyTypes.append(type)
            } else {
                filterItem.buyTypes = filterItem.buyTypes.filter { $0 != type }
            }
        }

        let minCost = Int(costSlider.selectedMinimum)
        let maxCost = Int(costSlider.selectedMaximum)
        filterItem.cost = minCost...maxCost
        
        let minSquare = Int(squareSlider.selectedMinimum)
        let maxSquare = Int(squareSlider.selectedMaximum)
        filterItem.square = minSquare...maxSquare
        
        let minRooms = Int(roomsSlider.selectedMinimum)
        let maxRooms = Int(roomsSlider.selectedMaximum)
        filterItem.rooms = minRooms...maxRooms
        
        let minFloor = Int(floorSlider.selectedMinimum)
        let maxFloor = Int(floorSlider.selectedMaximum)
        filterItem.floor = minFloor...maxFloor
    }
    
    @IBAction func typeButtonPressed(_ sender: UIButton) {
        let type = PropertyType(by: sender.tag)
        if sender.isSelected {
            filterItem.types = filterItem.types.filter { $0 != type }
        } else {
            filterItem.types.append(type)
        }
        
        delegate?.filterChangedValue(item: filterItem)
    }
    
    @IBAction func buyTypeButtonPressed(_ sender: UIButton) {
        let type = BuyType(by: sender.tag)
        if sender.isSelected {
            filterItem.buyTypes = filterItem.buyTypes.filter { $0 != type }
        } else {
            filterItem.buyTypes.append(type)
        }
        
        delegate?.filterChangedValue(item: filterItem)
    }
    
    @IBAction func costSliderChangedValue(_ sender: TTRangeSlider) {
        let min = Int(sender.selectedMinimum)
        let max = Int(sender.selectedMaximum)
        filterItem.cost = min...max
        
        delegate?.filterChangedValue(item: filterItem)
    }
    
    @IBAction func squareSliderChangedValue(_ sender: TTRangeSlider) {
        let min = Int(sender.selectedMinimum)
        let max = Int(sender.selectedMaximum)
        filterItem.square = min...max
        
        delegate?.filterChangedValue(item: filterItem)
    }
    
    @IBAction func roomsSliderChangedValue(_ sender: TTRangeSlider) {
        let min = Int(sender.selectedMinimum)
        let max = Int(sender.selectedMaximum)
        filterItem.rooms = min...max
        
        delegate?.filterChangedValue(item: filterItem)
    }
    
    @IBAction func floorSliderChangedValue(_ sender: TTRangeSlider) {
        let min = Int(sender.selectedMinimum)
        let max = Int(sender.selectedMaximum)
        filterItem.floor = min...max
        
        delegate?.filterChangedValue(item: filterItem)
    }
    
}

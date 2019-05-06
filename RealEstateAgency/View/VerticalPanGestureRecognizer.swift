//
//  BottomSheetPanGestureRecognizer.swift
//  Kidcoin
//
//  Created by Mediym on 12/22/18.
//  Copyright © 2018 Mediym. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class VerticalPanGestureRecognizer: UIPanGestureRecognizer {
    public enum Direction {
        case up, down, unknown
    }
    
    private var directionStart: CGPoint = .zero
    let distanceForChangeDirection: CGFloat = 10
    public var direction: Direction = .unknown
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        directionStart = touch.location(in: nil)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let ticklePoint = touch.location(in: nil)
        let moveDistance = ticklePoint.y - directionStart.y
        
        guard abs(moveDistance) >= distanceForChangeDirection else { return }
        
        direction = moveDistance < 0 ? .up : .down
        directionStart = ticklePoint
    }
}


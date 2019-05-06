//
//  CardVCProtocol.swift
//  Kidcoin
//
//  Created by Mediym on 12/26/18.
//  Copyright © 2018 Mediym. All rights reserved.
//

import UIKit

class CardVC: UIViewController {
    @IBOutlet weak var handledAreaView: UIView!
    
    var visualEffectView: UIVisualEffectView!
    var runningAnimations: [UIViewPropertyAnimator] = []
    var animationProgressWhenInterrupted: CGFloat = 0
    
    var animateDuration: TimeInterval = 0.4
    let safeAreaBottomInset: CGFloat = 34
    var cardVisible: Bool = false
    var nextState: Bool {
        return !cardVisible
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
    }
    

    
    func setup() {
        guard let superview = parent?.view else {
            print("[Error] CardVC have no superview!")
            return
        }
        
        self.view.clipsToBounds = true
        self.view.frame.size.width = superview.frame.width
        self.view.frame.origin.y = superview.frame.height - handledAreaView.frame.height
        if #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow {
            self.view.frame.origin.y -= window.safeAreaInsets.bottom
        }
        
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = superview.frame
        superview.insertSubview(visualEffectView, belowSubview: view)
        visualEffectView.isHidden = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        visualEffectView.addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = VerticalPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        handledAreaView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func heightWithSafeAreaInset(_ height: CGFloat? = nil) -> CGFloat {
        guard var height = height else {
            return view.frame.height
        }
        
        if #available(iOS 11.0, *),
            let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom  {
            height += bottomInset
        }
        
        return height
    }
    
    func close() {
        startInteractiveTransition(isOpeningDirection: nextState, duration: animateDuration)
        continueInteractiveTransition()
    }

    @objc func handleBackgroundTap() {
        close()
    }
    
    @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(isOpeningDirection: nextState, duration: animateDuration)
        case .changed:
            let transition = recognizer.translation(in: handledAreaView)
            var fractionComplete = transition.y / view.frame.height
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTrasitionIfNeeded(isOpeningDirection: Bool, duration: TimeInterval) {
        guard runningAnimations.isEmpty, let superview = parent?.view else { return }
        
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            var bottomSafeAreaPadding: CGFloat = 0
            if #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow {
                bottomSafeAreaPadding = window.safeAreaInsets.bottom
            }

            if isOpeningDirection {
                let height = self.view.frame.height - 12
                self.view.frame.origin.y = superview.frame.height - height - bottomSafeAreaPadding
            } else {
                self.view.frame.origin.y = superview.frame.height - self.handledAreaView.frame.height - bottomSafeAreaPadding

            }
        }
        
        frameAnimator.addCompletion { _ in
            self.parent?.navigationController?.isNavigationBarHidden = isOpeningDirection
            self.visualEffectView.isHidden = !isOpeningDirection
            
            self.cardVisible = !self.cardVisible
            self.runningAnimations.removeAll()
        }
        
        frameAnimator.startAnimation()
        runningAnimations.append(frameAnimator)
        
        let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            let radius: CGFloat = isOpeningDirection ? 12 : 0
            self.view.layer.cornerRadius = radius
        }
        
        cornerRadiusAnimator.startAnimation()
        runningAnimations.append(cornerRadiusAnimator)
        
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            if isOpeningDirection {
                self.visualEffectView.effect = UIBlurEffect(style: .dark)
            } else {
                self.visualEffectView.effect = nil
            }
        }
        
        blurAnimator.startAnimation()
        runningAnimations.append(blurAnimator)
        
    }
    
    func startInteractiveTransition(isOpeningDirection: Bool, duration: TimeInterval) {
        visualEffectView.isHidden = false
        parent?.navigationController?.isNavigationBarHidden = isOpeningDirection
        
        if runningAnimations.isEmpty {
            animateTrasitionIfNeeded(isOpeningDirection: isOpeningDirection, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
   
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    
    
}

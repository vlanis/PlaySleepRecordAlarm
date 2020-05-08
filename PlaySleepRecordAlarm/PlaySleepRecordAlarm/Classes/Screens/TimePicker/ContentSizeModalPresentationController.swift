//
//  ContentSizeModalPresentationController.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 08.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

final class ContentSizeModalPresentationController: UIPresentationController {
    
    // MARK:- Properties
    
    private var dimmedView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        return view
    }()
    
    // MARK:- Presentation
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }
        
        let dimmedViewAlpha: CGFloat = 0.5
        
        dimmedView.alpha = 0
        dimmedView.frame = containerView.bounds
        containerView.addSubview(dimmedView)
        
        transitionCoordinator.animate(alongsideTransition: { [unowned self] _ in
            self.dimmedView.alpha = dimmedViewAlpha
        }, completion: nil)
    }
    
    @objc private func dimmedViewTapped() {
        presentedViewController.dismiss(animated: true)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }
        
        transitionCoordinator.animate(alongsideTransition: { [unowned self] _ in
            self.dimmedView.alpha = 0
        }) { _ in
            self.dimmedView.removeFromSuperview()
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var contentSize = presentedViewController.preferredContentSize
        guard let containerView = containerView, contentSize != CGSize.zero else {
            return super.frameOfPresentedViewInContainerView
        }
        
        if #available(iOS 11, *) {
            contentSize.height += containerView.safeAreaInsets.bottom
        }
        
        contentSize.height = min(contentSize.height, containerView.bounds.height)
        contentSize.width = min(contentSize.width, containerView.bounds.width)
        
        var rect = containerView.bounds
        
        rect.origin.y = round(rect.height - contentSize.height)
        rect.size.height = round(contentSize.height)
        
        return rect
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    // MARK:- UIContentContainer
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        if container === presentedViewController {
            updatePresentedViewFrame()
        }
    }
    
    // MARK:- Presented View Resizing
    
    private func updatePresentedViewFrame(animated: Bool = true) {
        guard let presentedView = presentedView, presentedView.window != nil else {
            return
        }
        
        if animated {
            UIView.animate(withDuration: (animated ? 0.8 : 0),
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: { presentedView.frame = self.frameOfPresentedViewInContainerView },
                           completion: nil)
        }
    }
}

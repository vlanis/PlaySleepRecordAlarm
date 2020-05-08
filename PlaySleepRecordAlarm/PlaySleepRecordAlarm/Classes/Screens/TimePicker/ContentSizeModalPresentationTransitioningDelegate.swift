//
//  ContentSizeModalPresentationTransitioningDelegate.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 08.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

// TODO: move conformance to UIViewControllerTransitioningDelegate to a Presenter
final class ContentSizeModalPresentationTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    // while this is not in Presenter and since the delegate object doesn't encapsulate any states or data, it may be safely stored and reused multiple times for different presentations
    static let `default` = ContentSizeModalPresentationTransitioningDelegate()
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ContentSizeModalPresentationController(presentedViewController: presented, presenting: source)
    }
}

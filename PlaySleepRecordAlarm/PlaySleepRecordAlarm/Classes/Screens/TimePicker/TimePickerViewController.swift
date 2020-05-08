//
//  TimePickerViewController.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 07.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

// TODO: to decompose on View and ViewModel
final class TimePickerViewController: UIViewController {
    
    // MARK:- Properties
    
    static let storyboardIdentifier = "TimePickerViewControllerIdentifier"
    
    var initialDate: Date?
    
    @IBOutlet var datePicker: UIDatePicker! {
        didSet {
            datePicker.datePickerMode = .time
        }
    }
    
    @IBOutlet var toolbar: UIToolbar!
    
    private var didFinishHandler: ((_ date: Date) -> Void)?
    private var didCancelHandler: (() -> Void)?
    
    // MARK:- View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = initialDate ?? Date()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentSize()
    }
    
    // MARK:- Content Size
    
    func updateContentSize() {
        var contentSize = CGSize.zero
        contentSize.height = toolbar.frame.size.height + datePicker.frame.size.height
        contentSize.width = max(toolbar.frame.size.width, datePicker.frame.size.width)
        
        if preferredContentSize != contentSize {
            preferredContentSize = contentSize
        }
    }
    
    // MARK:- Actions
    
    @IBAction func cancelButtonPressed() {
        didCancelHandler?()
    }
    
    @IBAction func doneButtonPressed() {
        didFinishHandler?(datePicker.date)
    }
    
    // MARK:- Callbacks
    
    func didFinish(_ handler: ((_ date: Date) -> Void)?) {
        didFinishHandler = handler
    }
    
    func didCancel(_ handler: (() -> Void)?) {
        didCancelHandler = handler
    }
}

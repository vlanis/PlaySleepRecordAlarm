//
//  SleepAlarmViewController.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 07.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

final class SleepAlarmViewController: UIViewController {
    
    // MARK:- Properties
    
    static let storyboardIdentifier = "SleepAlarmViewControllerIdentifier"
    
    var viewModel: SleepAlarmViewModel! {
        willSet {
            viewModel?.shouldReloadSleepAlarmView(nil)
            viewModel?.shouldReloadPlaybackView(nil)
            viewModel?.shouldReloadStateView(nil)
        }
        
        didSet {
            viewModel?.shouldReloadSleepAlarmView { [weak self] in
                self?.reloadSleepAlarmList()
            }
            
            viewModel?.shouldReloadPlaybackView { [weak self] in
                self?.reloadPlaybackView()
            }
            
            viewModel?.shouldReloadStateView { [weak self] stateView in
                self?.reloadStateView(stateView)
            }
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.isScrollEnabled = false
        }
    }
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var stateContainerView: UIView!
    @IBOutlet var circleView: UIView! {
        didSet {
            circleView.layer.borderColor = UIColor.systemBlue.cgColor
            circleView.layer.borderWidth = 2
        }
    }
    
    @IBOutlet var idleStateLabel: UILabel! {
        didSet {
            idleStateLabel.text = NSLocalizedString("Please setup you sleep timer and alarm", comment: "Please setup you sleep timer and alarm")
        }
    }
    
    @IBOutlet var fallingAsleepStateLabel: UILabel! {
        didSet {
            fallingAsleepStateLabel.text = NSLocalizedString("Sweet dreams...", comment: "Sweet dreams...")
        }
    }
    
    @IBOutlet var sleepingStateLabel: UILabel! {
        didSet {
            sleepingStateLabel.text = "zzZ"
        }
    }
    
    @IBOutlet var alarmStateLabel: UILabel! {
        didSet {
            alarmStateLabel.text = "Rise and shine! =)"
        }
    }
    
    // MARK:- View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.requestPermissions()
        configureTransparentNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSleepAlarmList()
        reloadPlaybackView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let expectedCornerRadius = round(circleView.frame.size.height / 2)
        if circleView.layer.cornerRadius != expectedCornerRadius {
            circleView.layer.cornerRadius = expectedCornerRadius
        }
    }
    
    // MARK:- UI
    
    func configureTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
    }
    
    func reloadSleepAlarmList() {
        tableView.reloadData()
    }
    
    func reloadPlaybackView() {
        playButton.isHidden = viewModel.isRunnning ? true : false
        pauseButton.isHidden = !playButton.isHidden
    }
    
    func reloadStateView(_ stateView: StateView) {
        idleStateLabel.isHidden = (stateView == .idle) ? false : true
        fallingAsleepStateLabel.isHidden = (stateView == .fallingAsleep) ? false : true
        sleepingStateLabel.isHidden = (stateView == .sleeping) ? false : true
        alarmStateLabel.isHidden = (stateView == .alarm) ? false : true
    }
    
    // MARK:- Actions
    
    @IBAction func playButtonPressed() {
        viewModel.play()
    }
    
    @IBAction func pauseButtonPressed() {
        viewModel.pause()
    }
}

// MARK:- UITableViewDataSource
extension SleepAlarmViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellIdentifier, for: indexPath)
        row.configure(cell: cell, at: indexPath)
        
        return cell
    }
}

// MARK:- UITableViewDelegate
extension SleepAlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = viewModel.rows[indexPath.row]
        row.handleSelection(at: indexPath)
    }
}

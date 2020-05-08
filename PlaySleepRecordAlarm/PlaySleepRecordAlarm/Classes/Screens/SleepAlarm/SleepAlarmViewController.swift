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
    
    var viewModel: SleepAlarmViewModel! {
        willSet {
            viewModel?.shouldPresentSleepTimerOptions(nil)
            viewModel?.shouldReloadSleepAlarmView(nil)
            viewModel?.shouldPresentAlarmTimePicker(nil)
            viewModel?.shouldReloadPlaybackView(nil)
        }
        
        didSet {
            viewModel?.shouldPresentSleepTimerOptions { [weak self] options in
                self?.presentSleepTimerOptions(options)
            }
            
            viewModel?.shouldReloadSleepAlarmView { [weak self] in
                self?.reloadSleepAlarmList()
            }
            
            viewModel?.shouldPresentAlarmTimePicker { [weak self] alarmTime in
                self?.presentTimePicker(time: alarmTime)
            }
            
            viewModel?.shouldReloadPlaybackView { [weak self] in
                self?.reloadPlaybackView()
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
    
    // MARK:- View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // TODO: move assembling to a Presenter/Builder
        viewModel = SleepAlarmViewModelImp(audioPlayerController: AudioPlayerController(audioFileNamed: "nature", fileExtension: "m4a", loop: true)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSleepAlarmList()
        reloadPlaybackView()
    }
    
    // MARK:- UI
    
    func reloadSleepAlarmList() {
        tableView.reloadData()
    }
    
    func reloadPlaybackView() {
        playButton.isHidden = viewModel.isRunnning ? true : false
        pauseButton.isHidden = !playButton.isHidden
    }
    
    // MARK:- Actions
    
    @IBAction func playButtonPressed() {
        viewModel.play()
    }
    
    @IBAction func pauseButtonPressed() {
        viewModel.pause()
    }
    
    // MARK:- Events
    
    func didSelectSleepTimerOption(_ sleepTimer: SleepTimer) {
        viewModel.didSelectSleepTimerOption(sleepTimer)
    }
    
    func didSelectAlarmTime(_ alarmTime: Date) {
        viewModel.didSelectAlarmTime(alarmTime)
    }
    
    // MARK:- Presentation
    
    // TODO: all presentation from this section should be moved to a Presenter
    
    func presentSleepTimerOptions(_ options: [SleepTimer]) {
        let actionSheet = UIAlertController(title: NSLocalizedString("Sleep Timer", comment: "Sleep Timer"), message: nil, preferredStyle: .actionSheet)
        
        options.forEach { sleepTimer in
            let action = UIAlertAction(title: String(describing: sleepTimer), style: .default, handler: { [unowned self] _ in
                self.didSelectSleepTimerOption(sleepTimer)
            })
            actionSheet.addAction(action)
        }
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    func presentTimePicker(time: Date) {
        let timePickerViewController = UIStoryboard.main.instantiateViewController(withIdentifier: TimePickerViewController.storyboardIdentifier) as! TimePickerViewController
        
        timePickerViewController.modalPresentationStyle = .custom
        timePickerViewController.transitioningDelegate = ContentSizeModalPresentationTransitioningDelegate.default
        
        timePickerViewController.didFinish { [unowned self, timePickerViewController] time in
            self.didSelectAlarmTime(time)
            timePickerViewController.dismiss(animated: true)
        }
        
        timePickerViewController.didCancel { [unowned timePickerViewController] in
            timePickerViewController.dismiss(animated: true)
        }
        
        present(timePickerViewController, animated: true)
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

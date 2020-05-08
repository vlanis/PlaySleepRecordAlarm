//
//  AudioRecorderController.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 08.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioRecorderError: Error {
    case permissionDenied
}

protocol AudioRecorderControllable {
    var isRecording: Bool { get }
    
    func prepare(_ completion: ((_ error: Error?) -> Void)?)
    func record(_ completion: ((_ error: Error?) -> Void)?)
    func pause()
    func stop()
    
    func requestPermission(_ completion: @escaping (_ allowed: Bool) -> Void)
}

final class AudioRecorderController: AudioRecorderControllable {
    
    // MARK:- Properties
    
    private var audioRecorder: AVAudioRecorder?
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    // MARK:- Permission
    
    func requestPermission(_ completion: @escaping (_ allowed: Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission(completion)
    }
    
    // MARK:- Recording
    
    func prepare(_ completion: ((_ error: Error?) -> Void)? = nil) {
        stop()
        
        requestPermission { [unowned self] allowed in
            guard allowed else {
                completion?(AudioRecorderError.permissionDenied)
                return
            }
            
            let fileName = "recordedAudio_\(Date().compactString).m4a"
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]
            
            do {
                self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
                self.audioRecorder?.prepareToRecord()
                
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
    func record(_ completion: ((_ error: Error?) -> Void)? = nil) {
        func start() {
            try? AVAudioSession.sharedInstance().setActive(true)
            audioRecorder?.record()
        }
        
        if audioRecorder == nil {
            prepare { error in
                if error == nil {
                    start()
                    completion?(nil)
                } else {
                    completion?(error)
                }
            }
        } else {
            start()
            completion?(nil)
        }
    }
    
    func pause() {
        audioRecorder?.pause()
    }
    
    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

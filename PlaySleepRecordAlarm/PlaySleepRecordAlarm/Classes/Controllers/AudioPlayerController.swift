//
//  AudioPlayerController.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 08.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerControllable {
    var isPlaying: Bool {get}
    
    func play()
    func pause()
    func stop()
}

final class AudioPlayerController: AudioPlayerControllable {
    
    // MARK:- Properties
    
    private let audioPlayer: AVAudioPlayer
    
    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }
    
    // MARK:- Initialization
    
    init?(audioFileNamed: String, loop: Bool = false) {
        guard let fileURL = Bundle.main.url(forResource: audioFileNamed, withExtension: "m4a") else {
            return nil
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer.numberOfLoops = loop ? -1 : 0
        } catch {
            return nil
        }
    }
    
    // MARK:- Playback
    
    func play() {
        audioPlayer.play()
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    func stop() {
        audioPlayer.stop()
    }
}

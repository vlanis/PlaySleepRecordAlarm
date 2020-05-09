//
//  AudioPlayerControllerMock.swift
//  PlaySleepRecordAlarmTests
//
//  Created by Vlad Zhaglevskiy on 09.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
@testable import PlaySleepRecordAlarm

final class AudioPlayerControllerMock: AudioPlayerControllable {
    
    var isPlaying: Bool = false
    
    func play() {
        isPlaying = true
    }
    
    func pause() {
        isPlaying = false
    }
    
    func stop() {
        isPlaying = false
    }
}

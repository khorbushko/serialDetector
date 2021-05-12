//
//  View+SoundEffect.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 20.04.2021.
//

import Foundation
import SwiftUI
import AudioToolbox

enum SoundEffect: String {
  case copy = "copy"
  
  // MARK: - FilePrivate
  
  func play() {
    playSound(rawValue, type: type)
  }
  
  // MARK: - Private
  
  private var type: String {
    "wav"
  }
  
  private func playSound(_ name: String, type: String) {
    if let filePath = Bundle.main.path(forResource: name, ofType: type) {
      let url = URL(fileURLWithPath: filePath)
      
      var soundID: SystemSoundID = 0
      let error = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
      if error == kAudioServicesNoError {
        AudioServicesPlaySystemSoundWithCompletion(soundID, {
          AudioServicesDisposeSystemSoundID(soundID)
        })
      } else {
        assertionFailure("can't play audio \(error)")
      }
    }
  }
}

//
//  StringPastboard.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 20.04.2021.
//

import Foundation
import AppKit

final class StringPastboard {
  
  private let pastboard = NSPasteboard.general
  
  init() {
    pastboard.declareTypes([.string], owner: nil)
  }
  
  func copy(_ string: String) {
    pastboard.setString(string, forType: .string)
  }
}

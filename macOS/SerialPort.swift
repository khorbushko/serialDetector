//
//  SerialPortInfo.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 20.04.2021.
//

import Foundation
import SwiftUI

struct SerialPort: Identifiable, Codable {
  
  var id: String {
    "\(bsdPath.hash)"
  }
  
  /// IOCalloutDevice
  var bsdPath: String
  
  /// IOTTYBaseName
  var ttyName: String?
  
  /// IOTTYDevice
  var ttyDevice: String?
  
  /// IODialinDevice
  var dialinPath: String?
}

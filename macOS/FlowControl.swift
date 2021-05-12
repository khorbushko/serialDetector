//
//  FlowControl.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import Foundation

enum FlowControl: String, CaseIterable, Identifiable {
  case rts_cts = "RTS/CTS"
  case dtr_dsr = "DTR/DSR"
  case dcd = "DCD"
  
  var id: String { self.rawValue }
}

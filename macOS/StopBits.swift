//
//  StopBits.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import Foundation

enum StopBits: Int, CaseIterable, Identifiable {
  case zero = 1
  case one = 2
  
  var id: String { "\(self.rawValue)" }
}

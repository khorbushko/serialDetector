//
//  Parity.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import Foundation

enum Parity: String, CaseIterable, Identifiable {
  case none
  case odd
  case even
  
  var id: String { self.rawValue }
}

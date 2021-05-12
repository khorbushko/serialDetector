//
//  Suffix.swift
//  serialDetector
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import Foundation

enum Suffix: String, CaseIterable, Identifiable {
  
  case cr = "\r"
  case lf = "\n"
  case crls = "\r\n)"
  case none = ""
  
  var description: String {
    switch self {
      case .cr:
        return "CR (\\r}"
      case .lf:
        return "LF (\\n)"
      case .crls:
        return "CRLF (\\r\\n)"
      case .none:
        return "none"
    }
  }
  
  var id: String { self.rawValue }
}

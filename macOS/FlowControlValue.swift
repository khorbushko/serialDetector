//
//  FlowControlValue.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import Foundation

struct FlowControlValue {
  var id = UUID()
  let value: FlowControl
  var isSelected: Bool = false
}

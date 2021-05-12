//
//  BaudRate.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import Foundation

enum BaudRate: Int, CaseIterable, Identifiable {
  case _0 = 0
  case _50 = 50
  case _75 = 75
  case _110 = 110
  case _134 = 134
  case _150 = 150
  case _200 = 200
  case _300 = 300
  case _600 = 600
  case _1200 = 1200
  case _2400 = 2400
  case _4800 = 4800
  case _7200 = 7200
  case _9600 = 9600
  case _14400 = 14400
  case _19200 = 19200
  case _28800 = 28800
  case _38400 = 38400
  case _57600 = 57600
  case _76800 = 76800
  case _115200 = 115200
  case _128000 = 128000
  case _230400 = 230400
  case _256000 = 256000
  
  var id: String { "\(self.rawValue)" }
}

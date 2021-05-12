//
//  Environment+Settings.swift
//  serialDetector
//
//  Created by Kyryl Horbushko on 21.04.2021.
//

import Foundation
import SwiftUI

fileprivate struct SettingsStoreKey: EnvironmentKey {
  static let defaultValue: SettingsStore = .init()
}

extension EnvironmentValues {
  var settingsStore: SettingsStore {
    get {
      return self[SettingsStoreKey.self]
    }
    set {
      self[SettingsStoreKey.self] = newValue
    }
  }
}

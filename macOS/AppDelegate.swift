//
//  AppDelegate.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 20.04.2021.
//

import Foundation
import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusBar: StatusBarController?
//  var allowStatusBar: Bool = true
  
//  @Environment(\.settingsStore)
//  private var store: SettingsStore
  
  // MARK: - NSApplicationDelegate
  
  func applicationDidFinishLaunching(_ notification: Notification) {
//    if store.selectedPort == nil {
      let contentView = SerialPortListView(viewModel: .init(
        serialPortInspector: SerialPortDiscoverer.listener
      ))
      
      let mainView = NSHostingView(rootView: contentView)
      mainView.frame = NSRect(x: 0, y: 0, width: 300, height: 250)
      statusBar = StatusBarController(mainView)
//    }
//    NSApp.setActivationPolicy(.accessory)
  }
}

//
//  serialDetectorApp.swift
//  Shared
//
//  Created by Kyryl Horbushko on 19.04.2021.
//

import SwiftUI

@main
struct serialDetectorApp: App {
  
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate
  
//  @Environment(\.settingsStore)
//  private var store: SettingsStore
  
  var body: some Scene {
    WindowGroup {
      EmptyView()
        .frame(width: .zero)
    }
    .handlesExternalEvents(matching: [Window.main.rawValue])

//    WindowGroup("Console") {
//        SerialPortConsoleView(viewModel: .init(store: store))
//          .frame(width: 400, height: 600)
//          .handlesExternalEvents(preferring: [Window.console.rawValue], allowing: ["*"])
//    }
//    .handlesExternalEvents(matching: [Window.console.rawValue])
    
  }
}

enum Window: String {
  case main = "main"
  case console = "console"
  
  func open() {
    if let url = URL(string: "serialDetector://\(self.rawValue)") {
      NSWorkspace.shared.open(url)
    }
  }
}

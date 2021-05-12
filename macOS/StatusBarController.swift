//
//  StatusBarController.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 20.04.2021.
//

import Foundation
import SwiftUI
import AppKit

final class StatusBarController {
  
  private var statusBar: NSStatusBar
  private var statusItem: NSStatusItem
  private var mainView: NSView
  
  // MARK: - Lifecycle
  
  init(_ view: NSView) {
    mainView = view
    statusBar = NSStatusBar.system
    statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
    createMenu()
  }
  
  // MARK: - Private
  
  // MARK: - Actions
  
  @objc private func onQuitAction(_ sender: Any?) {
    NSApplication.shared.terminate(self)
  }
  
  @objc private func onSerialPortDB9InfoClick(_ sender: Any?) {
    showInfoViewFor(.db9)
  }
  
  @objc private func onSerialPortUSBInfoClick(_ sender: Any?) {
    showInfoViewFor(.usb)
  }
  
  // MARK: - MenuConfig
  
  private func createMenu() {
    if let statusBarButton = statusItem.button {
      statusBarButton.image = NSImage(named: "ic_serialPort")
      
      let serialListMenuItem = NSMenuItem()
      serialListMenuItem.title = "List of Serial Ports"
            
        let serialListDetailsMenuItem = NSMenuItem()
        serialListDetailsMenuItem.view = mainView
      
        let serialListDetailsMenu = NSMenu()
        serialListDetailsMenu.addItem(serialListDetailsMenuItem)
      
      let mainMenu = NSMenu()
        mainMenu.addItem(serialListMenuItem)
          mainMenu.setSubmenu(serialListDetailsMenu, for: serialListMenuItem)

      let serialPortInfo = NSMenuItem()
      serialPortInfo.title = "Serial Port info"

        let infoDB9Menu = NSMenuItem()
        infoDB9Menu.title = "DB9..."
        infoDB9Menu.target = self
        infoDB9Menu.action = #selector(Self.onSerialPortDB9InfoClick(_:))
      
        let infoUSBMenu = NSMenuItem()
        infoUSBMenu.title = "USB..."
        infoUSBMenu.target = self
        infoUSBMenu.action = #selector(Self.onSerialPortUSBInfoClick(_:))
      
        let serialPortInfoMenu = NSMenu()
        serialPortInfoMenu.addItem(infoDB9Menu)
        serialPortInfoMenu.addItem(infoUSBMenu)

        mainMenu.addItem(serialPortInfo)
          mainMenu.setSubmenu(serialPortInfoMenu, for: serialPortInfo)

      
      let quitMenuItem = NSMenuItem()
      quitMenuItem.title = "Quit"
      quitMenuItem.target = self
      quitMenuItem.action = #selector(Self.onQuitAction(_:))
      
      mainMenu.addItem(quitMenuItem)
      
      statusItem.menu = mainMenu
    }
  }
  
  private func showInfoViewFor(_ serialPortType: SerialPortType) {
    let view = SerialPortInfoView(type: serialPortType)
      .frame(width: 600, height: 600)
    let controller = NSHostingController(rootView: view)
    let window = NSWindow(contentViewController: controller)
    window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
    window.title = "Serial port structure: \(serialPortType.name)"
    let size = NSSize(width: 600, height: 600)
    window.setContentSize(size)
    window.makeKeyAndOrderFront(nil)
  }
}

enum SerialPortType {
  
  case db9
  case usb
  
  var imageName: String {
    switch self {
      case .db9:
        return "ic_serialPort_db9"
      case .usb:
        return "ic_serialPort_usb"
    }
  }
  
  var name: String {
    switch self {
      case .db9:
        return "DB9"
      case .usb:
        return "USB"
    }
  }
}

struct SerialPortInfoView: View {
  
  let type: SerialPortType
  
  var body: some View {
    Image(type.imageName)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .background(Color.white)
  }
}
